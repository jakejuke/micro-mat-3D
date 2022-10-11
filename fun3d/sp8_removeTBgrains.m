function fullGTs = sp8_removeTBgrains(full3Ds,fullGTs,varargin)
%sp8_removeTBgrains Remove grains from top/bottom of sample
%   
%   fullGTs = sp8_removeTBgrains(full3Ds,fullGTs) adds/updates the field
%   'badGrains' in the structure fullGTs. The field 'badGrains' is of type
%   logical and is true if a grain is near the very top or bottom surface
%   of the sample, otherwise false. This field can then be used later to
%   exclude grains from future analysis.
%   
%   The option 'num2remove' refers to the number of slices at the top and
%   bottom of the stack to remove. The default value is 15. User may want
%   to change this value depending on how many grains he wants to remove
%   from the top/bottom.
%   
%   
%   Jules Dake
%   Uni Ulm, 21 Nov 2014
%

%% Parse input variables
p = inputParser;

addRequired(p,'full3Ds',@iscell);
addRequired(p,'fullGTs',@isstruct);

defaultNum2Remove = 15;
addParameter(p,'num2remove',defaultNum2Remove,@isnumeric);

parse(p,full3Ds,fullGTs,varargin{:});

num2remove = p.Results.num2remove;


%% Detect grains at top/bottom

numTimeSteps = length(full3Ds);

A = false(size(full3Ds{1}));
A(:,:,1:num2remove) = 1; A(:,:,end-num2remove:end) = 1;

for I=1:numTimeSteps
    badGrains = unique(full3Ds{I}(A));
    badGrains = badGrains(badGrains > 0);
    try
        display([num2str(length(badGrains)) ' bad grains for timestep ' ...
            fullGTs(I).timestep])
    catch ME
        display([num2str(length(badGrains)) ' bad grains for simstep ' ...
            num2str(fullGTs(I).simstep)])
    end
    % Changed line below on 16 Apr 2016
    % fullGTs(I).badGrain = ismember(fullGTs(1).labels,badGrains);
    fullGTs(I).badGrain = ismember(fullGTs(I).labels,badGrains);
    clear badGrains
end


end

