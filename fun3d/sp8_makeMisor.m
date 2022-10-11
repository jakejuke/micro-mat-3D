function misor = sp8_makeMisor(fullGTs,varargin)
%SP8_MAKEMISOR makes misorientation matrix
%   
%   misor = SP8_MAKEMISOR(fullGTs) uses the multidimensional structure
%   fullGTs to create a misorientation matrix from the grain orientations
%   stored in fullGTs for the various timesteps.
%
%   Options
%   -------
%   misor = SP8_MAKEMISOR(fullGTs,'method',s1) where s1 is a string which
%   can either be 'absolute' or 'relative', default is 'absolute'.
%
%
%   Jules Dake
%   Uni Ulm, 17 Oct 2014
%

%% Parse input variables
p = inputParser;

addRequired(p,'fullGTs',@isstruct);

defaultMethod = 'absolute';
addParameter(p,'method',defaultMethod,@ischar);
defaultRate = 'off';
addParameter(p,'Rate',defaultRate,@ischar);
defaultMinRotLim = NaN;
addParameter(p,'MinRotLim',defaultMinRotLim,@isnumeric);

parse(p,fullGTs,varargin{:});

misorMethod  = p.Results.method;
rate = p.Results.Rate;
minRotLim = p.Results.MinRotLim;

% if strcmpi(misorMethod,'absolute')
%     display('Calculating misorientations relative to timestep 1')
% elseif strcmpi(misorMethod,'relative')
%     display('Calculating misorientations relative to previous timestep')
% else
%     error('Optional input method can only be ''absolute'' or ''relative''')
% end


%% Calculate misorientation
numTs = length(fullGTs);
numGs = length(fullGTs(1).labels);

misor = nan(numGs,numTs);

% misorientation relative to t=1
if strcmpi(misorMethod,'absolute')
    for I=2:numTs
        for J=1:numGs
            if isfinite(fullGTs(I).labels(J))
                misor(J,I) = mymisorientation(fullGTs(1).orient(J,:), ...
                    fullGTs(I).orient(J,:));
            end
        end
    end
    
% relative misorientation between timesteps    
elseif strcmpi(misorMethod,'relative')
    for I=2:numTs
        for J=1:numGs
            if isfinite(fullGTs(I).labels(J))
                misor(J,I) = mymisorientation(fullGTs(I-1).orient(J,:), ...
                    fullGTs(I).orient(J,:));
            end
        end
    end
    
elseif strcmpi(misorMethod,'CorrAll')
    clear misor
    maxDTs = numTs - 1;       % max delta timestep
    nc = maxDTs*(maxDTs+1)/2; % number of columns
    misor = nan(numGs,nc);    % misor matrix
    u = nan(1,nc);            % time between annealing steps
    mc = 0;
    
    for dTs = 1:maxDTs
        for I = 1:numTs-dTs
            c1 = I; c2 = I+dTs;
            mc = mc + 1;
            u(1,mc) = fullGTs(c2).time - fullGTs(c1).time;
            for J=1:numGs
                if isfinite(fullGTs(c2).labels(J))
                    misor(J,mc) = mymisorientation(fullGTs(c1).orient(J,:), ...
                        fullGTs(c2).orient(J,:));
                end
            end
        end
    end
    
end


if isfinite(minRotLim)
    misor(misor < minRotLim) = NaN;
end

if strcmpi(rate,'on')
    t = horzcat(fullGTs.time);
    if strcmpi(misorMethod,'relative')
        % calculate rotation rates
        for I=2:numTs
            misor(:,I) = misor(:,I)/(t(I)-t(I-1));
        end
    else
        display('Can only calculate rotation rates for ''relative'' misorientations')
        display('Set option: ''method'' to be ''relative''')
        error('sp8_makeMisor options conflict')
    end
end

% check if there are 'bad grains' that should be excluded
if isfield(fullGTs,'badGrain')
    display('Removing ''bad'' grains from misor matrix')
    badGrainIndex = sp8_excludeBadGrains(fullGTs);
    misor(badGrainIndex,:) = NaN;
else
    display('No ''bad'' grains')
end

if strcmpi(misorMethod,'CorrAll')
    misor = [u; misor];
end

end

