function grainTable = makeGrainTable(A,varargin)
%makeGrainTable Make grain table(s) for 3D grain data
%
%   Detailed explanation goes here
%
%   Options
% 
%   Relabel grains from 1 to max number of regions
%   Generate random orientations (to be coded)
% 
%   Jules Dake
%   Uni Ulm, Oct 24 2022
%


% Min/max value of Rodrigues vectors
minmaxR = (sqrt(2)-1);

% If input A is not a cell array, make a 1x1 cell array
if iscell(A)
    full3Ds = A;
else
    full3Ds{1} = A;
end


% Parse input variables
p = inputParser;

defaultRelabel = false;
defaultGenOrient = true;

addRequired(p,'A');
addParameter(p,'relabel',defaultRelabel,@islogical)
addParameter(p,'genOrient',defaultGenOrient,@islogical)

parse(p,A,varargin{:});

relabel = p.Results.relabel;
genOrient = p.Results.genOrient;


% Relabel from 1 to max number of grains
if relabel
    for R=1:length(full3Ds)
        full3Ds{R} = relabelGrainMat(full3Ds{R});
    end
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

if genOrient
    % generate random numbers for orientations
    randOrients = rand(length(grainLabels),3);
    % rescale for fundamental zone
    randOrients = (randOrients - 0.5)*minmaxR/0.5;
end


tempMat1 = nan(maxLabel,1);
tempMat3 = nan(maxLabel,3);

% Get region props for each 3D dataset
for R = 1:length(full3Ds)

    % Write grain labels to grain table
    currentLabels = unique(full3Ds{R});
    grainTable(R,1).labels = grainLabels;
    grainTable(R).labels(~ismember(grainLabels,currentLabels)) = nan;

    if genOrient
        % Write random grain orientations
        grainTable(R).orient = randOrients;
        grainTable(R).orient(isnan(grainTable(R).labels),:) = NaN;
    end
    grainTable(R).old = grainTable(R).orient;

    % If the grain with the largest grain label is not in the current
    % dataset, then the length of s could be shorter than the length of the
    % grain labels. This is why I write from 1 to sLength below.
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