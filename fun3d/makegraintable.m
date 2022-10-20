function grainTable = makegraintable(A,varargin)
%makegraintable Make grain table(s) from 3D matrix of grain labels
%
%   Detailed explanation goes here

%% Options
% 
% Relabel grains from 1 to max number of regions
% 


% If input A is not a cell array, make a 1x1 cell array
if iscell(A)
    full3Ds = A;
else
    full3Ds{1} = A;
end

% Find max grain label
maxLabel = 0;
for R = 1:length(full3Ds)
    maxX = nanmax(unique(full3Ds{R}));
    if maxX > maxLabel
        maxLabel = maxX;
    end
end

grainLabels = (1:maxLabel)';


% Set fields for grainTable
grainTable = struct('labels',nan(maxLabel,1),...
                    'orient',nan(maxLabel,3),...
                    'old',nan(maxLabel,3),...
                    'centroid',nan(maxLabel,3),...
                    'volume',nan(maxLabel,1),...
                    'gradius',nan(maxLabel,1));


for R = 1:length(full3Ds)
    % Write grain labels to grain table
    currentLabels = unique(full3Ds{R});
    grainTable(R).labels = grainLabels;
    grainTable(R).labels(~ismember(grainLabels,currentLabels)) = nan;

    s = regionprops(full3Ds{R});
    sLength = length([s.Area]);

    c = vertcat(s.Centroid);
    grainTable(R).centroid(1:sLength,:) = c;
end


end