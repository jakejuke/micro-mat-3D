%   Inputs:
%       A
%       fullGT
%       voxellist
%       goi
%       

load('~/Dropbox/matlab_code/sp8_bh/bh400_temp.mat')
initialVars = []; %#ok<NASGU>
initialVars = who;

clearvars('-except',initialVars{:})
% fullGT = fullGTs(1);
A = full3D;

% Find neighbors of grain of interest (goi)
% A = padarray(A, [1 1 1]);
%%
goi = 122;
% goi = 456;
% goi = 600;
minmaxR = (sqrt(2)-1);


% a = find(voxellist(:,2)==goi);
b = voxellist(voxellist(:,2)==goi,:);
neighbors_of_goi = b(:,3:8);
neighbors_of_goi = unique(neighbors_of_goi(isfinite(neighbors_of_goi)));
numNeighbors = numel(neighbors_of_goi);


% Ar = uint8(zeros(size(A)));
% Ag = uint8(zeros(size(A)));
% Ab = uint8(zeros(size(A)));
% Ar = nan(size(A));
% Ag = nan(size(A));
% Ab = nan(size(A));

% A2 = uint16(zeros(size(A)));
A2 = nan(size(A));
colorNeighbors = zeros(numNeighbors,3);

for I=1:length(neighbors_of_goi)
    %
    c = any(b(:,3:8)==neighbors_of_goi(I),2);
    boundaryVoxels = b(c,1);
    
%     row = find(fullGT(:,1)==neighbors_of_goi(I));
%     rgb2 = fullGT(row,2:4)*.5/minmaxR + 0.5;
%     Ar(boundaryVoxels) = rgb2(1);
%     Ag(boundaryVoxels) = rgb2(2);
%     Ab(boundaryVoxels) = rgb2(3);

    row = find(fullGT.old(:,1)==neighbors_of_goi(I));
    if row > 0
        colorNeighbors(I,:) = fullGT.old(row,2:4)*.5/minmaxR + 0.5;
    else
        colorNeighbors(I,:) = [0 0 0];
    end
    
    A2(boundaryVoxels) = neighbors_of_goi(I);
    
end


% colormap = fullGT(:,2:4)*.5/minmaxR + 0.5;

% [I,J,K] = ind2sub(size(A),boundaryVoxels);


% Now, how do I plot this surface???
%
% plot3(I,J,K,'d')?
%
% http://www.mathworks.com/matlabcentral/fileexchange/22940-vol3d-v2
% http://www.mathworks.com/matlabcentral/fileexchange/28497-plot-a-3d-array-using-patch
% http://www.mathworks.com/matlabcentral/answers/55633-how-to-drawing-3d-voxel-data
% 

figure
cmap = jet(numNeighbors);
scmap = cmap(randperm(size(cmap,1)),:);
PATCH_3Darray(A2,scmap,'col')
% PATCH_3Darray(A2,colorNeighbors,'col')

