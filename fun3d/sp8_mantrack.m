function sp8_mantrack(gnum,A0,A,GT0,GT,varargin)
%SP8_MANTRACK Function for manual tracking of 3DXRD grains across timesteps
% 
%   SP8_MANTRACK(gnum,A0,A,GT0,GT,varargin) - for a grain (gnum) in a given
%   timestep (3D matrix: A, grain table: GT), three cross sections through
%   the center of mass are displayed (in figure 2). The same three slices
%   for the previous timestep (3D matrix: A0, grain table: GT0) are shown
%   above in figure 1.
%   *Note: it is best to use registered 3D matrices
%
%   Optional inputs
%   ---------------
%       bwGBs - mark GBs in black; '0' or '1' (default 0)
%       minmaxR - min/max value for Rodrigues vector (default (sqrt(2)-1))
%
%   Example
%   -------
%   % For any given grain in reg3Ds{t}/fullGTs(t), shows slices through
%   % that grain's center of mass (xy, yz, xz).
%
%       t = 3; t0 = 2;
%       g = 300;
%       sp8_mantrack(g,reg3Ds{t0},reg3Ds{t},fullGTs(t0),fullGTs(t),'bwGBs',1)
%
%
%   Jules Dake
%   Uni Ulm, 6 Oct 2014
%


%% Parse input variables
p = inputParser;

addRequired(p,'grains',@isnumeric);
addRequired(p,'A0',@isnumeric);
addRequired(p,'A',@isnumeric);
addRequired(p,'GT0',@isstruct);
addRequired(p,'GT',@isstruct);

defaultGBblack = 0;
addParameter(p,'bwGBs',defaultGBblack,@isnumeric);
defaultMinMaxR = (sqrt(2)-1);
addParameter(p,'minmaxR',defaultMinMaxR,@isnumeric);

parse(p,gnum,A0,A,GT0,GT,varargin{:});

bwGBs = logical(p.Results.bwGBs);
minmaxR = p.Results.minmaxR;


%% Preallocate colormaps
cmap1 = zeros(length(GT0.labels)+1,3);
cmap2 = zeros(length(GT.labels)+1,3);
cmap1(1,:) = [0 0 0]; cmap2(1,:) = [0 0 0];
cmap1(2:end,:) = GT0.orient*.5/minmaxR + 0.5;
cmap2(2:end,:) = GT.orient*.5/minmaxR + 0.5;
if any(cmap1(:) > 1) || any(cmap1(:) < 0)
    error('There are Rodrigues vectors outside the fundamental zone for cubic symmetry!')
elseif any(cmap2(:) > 1) || any(cmap2(:) < 0)
    error('There are Rodrigues vectors outside the fundamental zone for cubic symmetry!')
end


%% Main code
posRC = findcom(gnum,A);
centerXY = uint16(posRC(3));
centerYZ = uint16(posRC(2));
centerXZ = uint16(posRC(1));

if bwGBs
    % % slow in 3D
    % B = sp8_gbextract(A0); A0(B>0) = 0;
    % B = sp8_gbextract(A); A(B>0) = 0;
    
    % much faster to do in 2D for all three slices
    [xl, yl, zl] = size(A);
    % 1
    imslice = A0(:,:,centerXY);
    imslice(sp8_gbextract2D(imslice)>0) = 0;
    A0(:,:,centerXY) = imslice;
    % 2
    imslice = squeeze(A0(:,centerYZ,:));
    imslice(sp8_gbextract2D(imslice)>0) = 0;
    imslice = reshape(imslice,xl,1,zl);
    A0(:,centerYZ,:) = imslice;
    % 3
    imslice = squeeze(A0(centerXZ,:,:));
    imslice(sp8_gbextract2D(imslice)>0) = 0;
    imslice = reshape(imslice,1,yl,zl);
    A0(centerXZ,:,:) = imslice;
    
    % 1
    imslice = A(:,:,centerXY);
    imslice(sp8_gbextract2D(imslice)>0) = 0;
    A(:,:,centerXY) = imslice;
    % 2
    imslice = squeeze(A(:,centerYZ,:));
    imslice(sp8_gbextract2D(imslice)>0) = 0;
    imslice = reshape(imslice,xl,1,zl);
    A(:,centerYZ,:) = imslice;
    % 3
    imslice = squeeze(A(centerXZ,:,:));
    imslice(sp8_gbextract2D(imslice)>0) = 0;
    imslice = reshape(imslice,1,yl,zl);
    A(centerXZ,:,:) = imslice;
    
end

% Add ring around GOI
B2 = A==gnum;
se = strel(ones(3,3,3));
BD = imdilate(B2,se);
% set color of ring around grain to red
BD = xor(BD, B2);
A(BD) = length(GT.labels) + 1;
cmap2(size(cmap2,1)+1,:) = [1 0 0];


%% Make plots
%%% NOTE:
% I have to make two figures because MATLAB does not allow two colormaps to
% be used with 'imshow'. 'subimage' does, but it does not show the index
% number anymore, i.e. the grain label, so it is also of no use.
%%%
% A1 slices at centroid of gnum in A2
imslice = A0(:,:,centerXY);
figure; set(gcf,'Units','normalized','Position',[0 .5 1 .4])
subplot(1,3,1); imshow(imslice,cmap1); axis equal
title(['xy-slice (z = ' num2str(centerXY) ')'])
axis off
imslice = transpose(squeeze(A0(:,centerYZ,:)));
subplot(1,3,2); imshow(imslice,cmap1); axis equal
title(['yz-slice (x = ' num2str(centerYZ) ')'])
axis off
imslice = transpose(squeeze(A0(centerXZ,:,:)));
subplot(1,3,3); imshow(imslice,cmap1); axis equal
title(['xz-slice (y = ' num2str(centerXZ) ')'])
axis off
% A2 slices through centroid of gnum
imslice = A(:,:,centerXY);
figure; set(gcf,'Units','normalized','Position',[0 0 1 .4])
subplot(1,3,1); imshow(imslice,cmap2); axis equal
title(['xy-slice (z = ' num2str(centerXY) ')'])
% xlabel('x'); ylabel('y')
axis off
imslice = transpose(squeeze(A(:,centerYZ,:)));
subplot(1,3,2); imshow(imslice,cmap2); axis equal
title(['yz-slice (x = ' num2str(centerYZ) ')'])
% xlabel('y'); ylabel('z')
axis off
imslice = transpose(squeeze(A(centerXZ,:,:)));
subplot(1,3,3); imshow(imslice,cmap2); axis equal
title(['xz-slice (y = ' num2str(centerXZ) ')'])
% xlabel('x'); ylabel('z')
axis off


end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%

function posRC = findcom(grain,A)
% Find position of center of mass in row/column format

A(A~=grain) = 0;
s = regionprops(A,'Centroid');

if isempty(s)
    error(['Grain ' num2str(grain) ' is not present in data set!'])
end

centroid = s(grain).Centroid;
% save centroid position in Row/Column format
posRC(1) = centroid(2); posRC(2) = centroid(1); posRC(3) = centroid(3);

end

