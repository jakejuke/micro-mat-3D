function [crop3Ds, BB] = sp8_extract3Dgrains(g,full3Ds,fullGTs,varargin)
%sp8_extract3Dgrains Extract grain(s) from 3D volume for all timesteps
%   
%   new3Ds = sp8_extract3Dgrains(g,full3Ds,fullGTs) extracts grains (g) in
%   3D from a larger 3D matrix.
%   
%   
%   Jules Dake
%   Uni Ulm, 12 Mar 2015
%   


%% Parse input variables
p = inputParser;

addRequired(p,'g',@isnumeric);
addRequired(p,'full3Ds',@iscell);
addRequired(p,'fullGTs',@isstruct);

parse(p,g,full3Ds,fullGTs);


%% Set BoundingBox
% getBoundingBox returns the 'BoundingBox' as:
%   BB = [xMin, yMin, zMin, xMax, yMax zMax]
%   *This is different than the 'BoundingBox' returned by regionprops!

for I=1:length(full3Ds)
    tempBB{I} = getBoundingBox(g(ismember(g,full3Ds{I})),full3Ds{I});
end

BB = vertcat(tempBB{:});
xMin = min(BB(:,1)); yMin = min(BB(:,2)); zMin = min(BB(:,3));
xMax = max(BB(:,4)); yMax = max(BB(:,5)); zMax = max(BB(:,6));

% TEMP fix 8 May 2016 %
[yS, xS, zS] = size(full3Ds{1});
if xMax > xS
    xMax = xS;
end
if yMax > yS
    yMax = yS;
end
if zMax > zS
    zMax = zS;
end
% END temp fix %


%% Apply BoundingBox to all timesteps and set other grains to zero
crop3Ds = cell(size(full3Ds));

for I=1:length(full3Ds)
    A = full3Ds{I}(yMin:yMax,xMin:xMax,zMin:zMax);
    B = ismember(A,g);
    A(~B) = 0;
    crop3Ds{I} = A;
end

end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%

% get label and orientation for GOI and make a mini Grain Table
function miniGT = makeMiniGT(fullGTs,goi);

miniGT = struct('labels',[],'orient',[],'time',[]);

for I=1:length(fullGTs)
    miniGT(I,1).labels = fullGTs(I).labels(goi);
    miniGT(I,1).orient = fullGTs(I).orient(goi,:);
    miniGT(I,1).time = fullGTs(I).time;
end

end


% get bounding box
function BB = getBoundingBox(g,A)

if isempty(g)
    BB = nan(1,6);
    return
end

B = A == g(1);
for I=2:length(g)
    B = or(B, A == g(I));
end

A(~B) = 0;

STATS = regionprops(A,'BoundingBox');
tempBB = STATS(g(1)).BoundingBox;
for I=2:length(g)
    tempBB = [tempBB; STATS(g(I)).BoundingBox];
end

xMin = floor(min(tempBB(:,1)));
yMin = floor(min(tempBB(:,2)));
zMin = floor(min(tempBB(:,3)));
xMax = ceil(max(tempBB(:,1) + tempBB(:,4)));
yMax = ceil(max(tempBB(:,2) + tempBB(:,5)));
zMax = ceil(max(tempBB(:,3) + tempBB(:,6)));

BB = [xMin, yMin, zMin, xMax, yMax zMax];

end


