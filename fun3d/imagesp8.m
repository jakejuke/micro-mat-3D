function imagesp8(slice,grainTable,varargin)
%IMAGEJD Plots 3DXRD data with RGB values from the Rodrigues vectors
%   
%   IMAGEJD(C,T) displays the 2D slice as an image with colors
%   representing the orientation in Rodrigues notation. The matrix
%   grainTable must be a structure with the field - 'orient'.
%   
%   
%   Examples:   imagejd(full3D(150,:,:),fullGT)
%               imagejd(full3D(:,150,:),fullGT)
%               imagejd(full3D(:,:,250),fullGT)
%
% Jules Dake, Uni Ulm, June 2014
% Test


%% Parse input variables
p = inputParser;

addRequired(p,'slice',@isnumeric);
addRequired(p,'grainTable',@isstruct);
defaultGBblack = 0;
addParameter(p,'bwGBs',defaultGBblack,@islogical);
parse(p,slice,grainTable,varargin{:});
bwGBs = logical(p.Results.bwGBs);

minmaxR = (sqrt(2)-1);
% minmaxR = .5
imslice = uint16(squeeze(slice));
if bwGBs
    B = sp8_gbextract2D(imslice);
    imslice(B>0) = 0;
end

grainOrients = grainTable.orient;
if any(isnan(grainOrients(:)))
    display('Some orientations are NaN''s')
    grainOrients(isnan(grainOrients)) = 0;
end

colormap = zeros(length(grainTable.labels) + 1,3);
colormap(1,:) = [0 0 0];
colormap(2:end,:) = grainOrients*.5/minmaxR + 0.5;
if any(colormap(:) > 1) || any(colormap(:) < 0)
    error('There are Rodrigues vectors outside the fundamental zone for cubic symmetry!')
end

% if nargin == 2
%     imshow(imslice,colormap); % axis equal
% elseif nargin == 3
%     subimage(imslice,colormap);
% end

imshow(imslice,colormap); % axis equal
    
end

