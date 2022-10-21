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

% Set fields for grainTable
grainTable = struct('timestep',[],'old',[],'labels',[],'orient',[],...
    'centroid',[],'volume',[],'gradius',[]);

% Find max grain label
maxLabel = 0;
for R = 1:length(full3Ds)
    maxX = nanmax(unique(full3Ds{R}));
    if maxX > maxLabel
        maxLabel = maxX;
    end
end

grainLabels = (1:maxLabel)';

tempMat1 = nan(maxLabel,1);
tempMat3 = nan(maxLabel,3);

% get region props
for R = 1:length(full3Ds)
    % Write grain labels to grain table
    currentLabels = unique(full3Ds{R});
    grainTable(R,1).labels = grainLabels;
    grainTable(R).labels(~ismember(grainLabels,currentLabels)) = nan;

    s = regionprops(full3Ds{R});
    sLength = length([s.Area]);

    grainTable(R).centroid = tempMat3;
    c = vertcat(s.Centroid);
    grainTable(R).centroid(1:sLength,:) = c;

    grainTable(R).volume = tempMat1;
    v = vertcat(s.Area);
    v(v==0) = nan;
    grainTable(R).volume(1:sLength) = v;

    grainTable(R).gradius = (grainTable(R).volume * 0.75/pi).^(1/3);
end


end