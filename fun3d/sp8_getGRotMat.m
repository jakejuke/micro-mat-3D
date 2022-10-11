function gRotMat = sp8_getGRotMat(fullGTs,varargin)
%sp8_getGRotMat
%   
%   gRotMat = sp8_getGRotMat(fullGTs,varargin) uses the multidimensional
%   structure fullGTs to create a misorientation matrix from the grain
%   orientations stored in fullGTs for the various timesteps.
%
%   Options
%   -------
%   Method: 'absolute' (def) or 'relative'
%   Rate: 'off' (def) or 'on'
%   MinRotLim: NaN (def) or some value in degrees; rotations smaller than
%              this value enter the gRotMat as NaNs
%
%
%   Jules Dake
%   Uni Ulm, 17 Oct 2014
%

%% Parse input variables
p = inputParser;

addRequired(p,'fullGTs',@isstruct);

defaultMethod = 'absolute';
addParameter(p,'Method',defaultMethod,@ischar);
defaultRate = 'off';
addParameter(p,'Rate',defaultRate,@ischar);
defaultMinRotLim = NaN;
addParameter(p,'MinRotLim',defaultMinRotLim,@isnumeric);

parse(p,fullGTs,varargin{:});

misorMethod  = p.Results.Method;
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

gRotMat = nan(numGs,numTs);

% misorientation relative to t=1
if strcmpi(misorMethod,'absolute')
    for I=2:numTs
        for J=1:numGs
            if isfinite(fullGTs(I).labels(J))
                gRotMat(J,I) = mymisorientation(fullGTs(1).orient(J,:), ...
                    fullGTs(I).orient(J,:));
            end
        end
    end
    
% relative misorientation between timesteps    
elseif strcmpi(misorMethod,'relative')
    for I=2:numTs
        for J=1:numGs
            if isfinite(fullGTs(I).labels(J))
                gRotMat(J,I) = mymisorientation(fullGTs(I-1).orient(J,:), ...
                    fullGTs(I).orient(J,:));
            end
        end
    end
    
% combine all possible timesteps of different lengths    
elseif strcmpi(misorMethod,'CorrAll')
    clear misor
    maxDTs = numTs - 1;       % max delta timestep
    nc = maxDTs*(maxDTs+1)/2; % number of columns
    gRotMat = nan(numGs,nc);    % misor matrix
    u = nan(1,nc);            % time between annealing steps
    mc = 0;
    
    for dTs = 1:maxDTs
        for I = 1:numTs-dTs
            c1 = I; c2 = I+dTs;
            mc = mc + 1;
            u(1,mc) = fullGTs(c2).time - fullGTs(c1).time;
            for J=1:numGs
                if isfinite(fullGTs(c2).labels(J))
                    gRotMat(J,mc) = mymisorientation(fullGTs(c1).orient(J,:), ...
                        fullGTs(c2).orient(J,:));
                end
            end
        end
    end
    
end


if isfinite(minRotLim)
    gRotMat(gRotMat < minRotLim) = NaN;
end

if strcmpi(rate,'on')
    t = horzcat(fullGTs.time);
    if strcmpi(misorMethod,'relative')
        % calculate rotation rates
        for I=2:numTs
            gRotMat(:,I) = gRotMat(:,I)/(t(I)-t(I-1));
        end
    else
        display('Can only calculate rotation rates for ''relative'' misorientations')
        display('Set option: ''method'' to be ''relative''')
        error('sp8_getGRotMat options conflict')
    end
end

% check if there are 'bad grains' that should be excluded
if isfield(fullGTs,'badGrain')
    display('Removing ''bad'' grains from misor matrix')
    badGrainIndex = sp8_excludeBadGrains(fullGTs);
    gRotMat(badGrainIndex,:) = NaN;
else
    display('No ''bad'' grains')
end

if strcmpi(misorMethod,'CorrAll')
    gRotMat = [u; gRotMat];
end

end

