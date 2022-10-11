function [posXY, posRC] = sp8_findgrain(grain,A,GT,varargin)
%SP8_FINDGRAIN - Finds locations of grains in a 3D matrix
%   
%   Input:
%       grain           Labels of grains to look for
%       A               3D matrix with unique grain labels
%       (grainTable)    For coloring
%       
%   Output:
%       posXY = position in x,y,z of grain's centroid
%       posRC = position in row, column, height
%   
%   Examples:
%       sp8_findgrains(grains,full3D,fullGT);
%       [posXY, posRC] = sp8_findgrains(grains,full3D,fullGT);
%       sp8_findgrains(grains,full3D,fullGT,'bwGBs',1);
%   
%
%   By Jules Dake, Uni Ulm, Germany
%   Jan 2014, rev. May 2014, June 2014
%



%% Parse input variables
p = inputParser;

addRequired(p,'grain',@isnumeric);
addRequired(p,'A',@isnumeric);
addRequired(p,'GT',@isstruct);

defaultGBblack = 0;
addParameter(p,'bwGBs',defaultGBblack,@isnumeric);
defaultMinMaxR = (sqrt(2)-1);
% defaultMinMaxR = .5
addParameter(p,'minmaxR',defaultMinMaxR,@isnumeric);
defaultPlot = 'on';
addParameter(p,'plot',defaultPlot,@(x)validateattributes(x,{'char'},{'nonempty'}));

parse(p,grain,A,GT,varargin{:});
bwGBs = logical(p.Results.bwGBs);
minmaxR = p.Results.minmaxR;

grainTable = GT.orient;
if any(isnan(grainTable(:)))
    display('Some orientations are NaN''s')
    grainTable(isnan(grainTable)) = 0;
end


%% Check if bwGBs set; if so, erode grain boundaries
if bwGBs
   B = sp8_gbextract(A);
   A(B>0) = 0;
end


%% Preallocate some variables
% posXY: position of center of mass in x,y-coordinates
% posXY: position of center of mass in row,column-coordinates
GT.labels = 1:length(GT.labels);
posXY = zeros(1,4);
posRC = uint16(zeros(1,4));
% colormap = zeros(size(grainTable,1)+1,3);
mycolormap = zeros(max(GT.labels)+1,3);
mycolormap(1,:) = [0 0 0];
% colormap(2:end,:) = grainTable*.5/minmaxR + 0.5;
mycolormap(GT.labels+1,:) = grainTable*.5/minmaxR + 0.5;
if any(mycolormap(:) > 1) || any(mycolormap(:) < 0)
    error('There are Rodrigues vectors outside the fundamental zone for cubic symmetry!')
end


%% Main code
% I = find(grainTable(:,1)==grain);
% colorGrain = colormap(I+1,:); % I+1 because top row of zeros added above

colorGrain = mycolormap(grain+1,:); % I+1 because top row of zeros added above

% regionprops of binary data give volume and centriod of the grain
s = regionprops(A==grain);

if isempty(s)
    % quit function
    error(['Grain ' num2str(grain)...
        ' is not present in data set!'])
elseif length(horzcat(s.Area)) > 1
    
    % sortedGrains = flip(sort(horzcat(s.Area))); % Works with 2014+
    sortedGrains = fliplr(sort(horzcat(s.Area)));
    largestGrain = sortedGrains(1);
    restGrains = sum(sortedGrains(2:end));
    voxelRatio = largestGrain/(restGrains+largestGrain)*100;
    
    display(['Grain ' num2str(grain) ...
        ' consists of multiple unconnected objects.'])
    display(['Largest object has ' num2str(voxelRatio) ...
        '% of total voxels.'])
else
    % Do nothing; only one object.
end

[~, I] = max(horzcat(s.Area));
centroid = s(I).Centroid;
boundingBox = vertcat(s.BoundingBox);
xMin = min(boundingBox(:,1));
yMin = min(boundingBox(:,2));
zMin = min(boundingBox(:,3));
xMax = max(boundingBox(:,1) + boundingBox(:,4));
yMax = max(boundingBox(:,2) + boundingBox(:,5));
zMax = max(boundingBox(:,3) + boundingBox(:,6));
% TEMP fix 26 Feb 2017 %
[yS, xS, zS] = size(A);
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

% TEMP fix 14 Apr 2021 %
if zMin < 1
    zMin = 1;
end

% save centroid position
posXY(1,1) = grain;
posRC(1,1) = grain;
posXY(1,2:end) = centroid;
posRC(1,2) = posXY(1,3); posRC(1,3) = posXY(1,2); posRC(1,4) = posXY(1,4);


%% Find BoundingBox
% It seems I don't need to do this for Isosurface, it does it automatically!
% B = imcrop(A,boundingBox); % doesn't seem to work
B = A(floor(yMin):ceil(yMax),...
      floor(xMin):ceil(xMax),...
      floor(zMin):ceil(zMax));
B = padarray(B, [3 3 3]);
B = B==grain;

% Add ring around GOI
B2 = A==grain;
se = strel(ones(3,3,3));
BD = imdilate(B2,se);
% set color of ring around grain to red
BD = xor(BD, B2);
% A(BD) = length(grainTable) + 1;
A(BD) = size(mycolormap,1) + 1;
mycolormap(size(mycolormap,1)+1,:) = [1 0 0];

if strcmpi(p.Results.plot,'on')
    % plot slices containing the grain's centroids
    centerXY = uint16(posRC(1,end));
    centerYZ = uint16(posRC(1,end-1));
    centerXZ = uint16(posRC(1,end-2));
    
    % imslice = label2rgb(A(:,:,centerXY), colormap, 'k');
    imslice = A(:,:,centerXY);
    figure; subplot(2,2,1); imshow(imslice,mycolormap); axis equal
    title(['xy-slice (z = ' num2str(centerXY) ')'])
    xlabel('x (px)')
    ylabel('y (px)')
    imslice = transpose(squeeze(A(:,centerYZ,:)));
    subplot(2,2,2); imshow(imslice,mycolormap); axis equal
    title(['yz-slice (x = ' num2str(centerYZ) ')'])
    xlabel('y (px)')
    ylabel('z (px)')
    imslice = transpose(squeeze(A(centerXZ,:,:)));
    subplot(2,2,3); imshow(imslice,mycolormap); axis equal
    title(['xz-slice (y = ' num2str(centerXZ) ')'])
    xlabel('x (px)')
    ylabel('z (px)')
    subplot(2,2,4); %isosurface(B);
    p = patch(isosurface(B));
    % p=patch(isosurface(A==grains(lp)));
    set(p,'FaceColor',colorGrain,'EdgeColor','none','AmbientStrength',0.4)
    axis equal; axis tight; axis off;
    view(3); camlight; lighting gouraud
    % % If you want correct axis labels run this instead:
    % subplot(2,2,4); isosurface(A==grains(lp)); axis equal; axis tight;
    % view(3); camlight; lighting gouraud
    
    set(gcf,'Units','normalized','Position',[.5 .5 .5 4/3/2])
end

end

