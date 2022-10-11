function LAGPs = sp8_getLAGPs(fullGTs,varargin)
%sp8_rotLAGBs gets unique low-angle grain pairs
%       
%   This function looks for unique low-angle grain pairs (i.e., grains with
%   only one low-angle grain boundary) across all time steps of the grain
%   table fullGTs. It returns a cell array the length of fullGTs with the
%   grain IDs and misorientation.
%   
%   
%   Optional inputs
%   ---------------
%       'misorLim' - default 15 degrees
%       'absUnique' - only exactly two grains are allowed, i.e. no chains
%                     of LAGBs
%   
%   Example
%   -------
%       g = sp8_rotMinGB(fullGTs,'minRotLim',1,'misorNNLim',15,'plot','surface')
%
%   
%   Jules Dake
%   Uni Ulm, 10 Dec 2015
%       


%% Parse input and set variables
p = inputParser;

addRequired(p,'fullGTs',@isstruct);
defMisorLim = 15;
addParameter(p,'MisorLim',defMisorLim,@isnumeric);
defAbsUnique = false;
addParameter(p,'absUnique',defAbsUnique,@islogical);

parse(p,fullGTs,varargin{:});
misorLim = p.Results.MisorLim;
absUnique = p.Results.absUnique;

%preallocation
LAGPs = cell(length(fullGTs),1);

% check if there are 'bad grains' that should be excluded
if isfield(fullGTs,'badGrain')
    display('Removing ''bad'' grains from misor matrix')
    badGrainIndex = sp8_excludeBadGrains(fullGTs);
    for T=1:length(fullGTs)
        fullGTs(T).labels(badGrainIndex) = NaN;
    end 
else
    display('No ''bad'' grains')
end


%% Find grains with only one LAGB
% For all grains in all time steps
for T = 1:length(fullGTs)
    nnTemp = nan(length(fullGTs(T).labels),3);
    for GOI = 1:length(fullGTs(T).labels)
        if isfinite(fullGTs(T).labels(GOI))
            % get all non-zero neighbors
            NN = fullGTs(T).NN{GOI}(fullGTs(T).NN{GOI}>0);
            % determine misorientation of all neighbors
            misorArray = zeros(1,length(NN));
            for I = 1:length(NN)
                misorArray(I) = mymisorientation(fullGTs(T).orient(GOI,:),...
                    fullGTs(T).orient(NN(I),:));
            end
            % save the grain if it only has one LAGB and is NOT a bad grain
            if sum(misorArray < misorLim) == 1
                NOI = NN(misorArray < misorLim);
                MIS = misorArray(misorArray < misorLim);
                if isfinite(fullGTs(T).labels(NOI))
                    nnTemp(GOI,:) = [fullGTs(T).labels(GOI), NOI, MIS];
                end
            end
        end
    end 
    % remove NaN enteries
    nnTemp = nnTemp( isfinite(nnTemp(:,1)),: );
    LAGPs{T} = removeDuplicates(nnTemp);
    
    % First column is unique, the second may not be... check this and
    % remove all non-unique entries if option is set
    if absUnique
        A = LAGPs{T}(:,2);
        [N, BINS] = histc(A, unique(A));
        MULTI = find(N > 1);
        INDX    = find(ismember(BINS, MULTI));
        LAGPs{T}(INDX,:) = [];
    end
    
    % User feedback
    fprintf('Found %d unique grain pairs in time step %s \n',...
        length(LAGPs{T}), fullGTs(T).timestep)
    
end

end


% remove rows from a matrix
function A = removeDuplicates(A)

I = 1;
% uses while loop because the size of A is changing
while I <= length(A)
    G21 = [A(I,2) A(I,1)];
    A(~all( bsxfun(@minus,A(:,1:2),G21),2 ),:) = [];
    I = I + 1;
end

end