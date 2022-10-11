%% SP8_ANALYZE_REGCT
%
% Registers CT to (already registered) 3DXRD data
%


% clc; clear;

cropTopXR = 22; cropBotXR = 525;
cropTopCT = 62; cropBotCT = 665;
maxIt = 100;
% set timestep for RB 1-4, for RD 1-6
N = 1;


%% Binarize
% ---
% Takes a while; only have to run once and then load the data like in next
% section
% ---
% timesteps for Rubber Beaver
timesteps = {'00';'10';'30';'60'};
imDirStem = '~/sp8_2013/ct_rb/stitched/rb';

binarGBs = cell(length(timesteps),1);
stackRaw = cell(length(timesteps),1);
stackMask = cell(length(timesteps),1);

for I=1:length(timesteps)
    [binarGBs{I}, stackRaw{I}, stackMask{I}] = ...
        tw_binarizeSP8([imDirStem timesteps{I} '/']);
end


%% Load binary CT and 3DXRD data sets for registration
s_ct = load('~/sp8_2013/ct_rb/MOUT_rbAll_binarCT.mat',...
    'stackRaw','stackMask','binarGBs');
ctRaw = s_ct.stackRaw; ctMask = s_ct.stackMask; ctGBs = s_ct.binarGBs;
clear s_ct

s_xr = load('~/Dropbox/matlab_code/sp8_rb/MOUT_rbAll_qtrack.mat',...
    'reg3Ds','mtkGTs');
xrd3Ds = s_xr.reg3Ds; xrdGTs = s_xr.mtkGTs;
clear s_xr


%% Extract "internal" GBs from 3DXRD data
A = xrd3Ds{N};
B = sp8_gbextract(A);
voxlist = sp8_gbVoxelList(A,'gbMat',B);
voxels_with_zero_neighbors = any(voxlist(:,3:8)==0,2);
B_zeros_ind = voxlist(voxels_with_zero_neighbors,1);
Bint = B;
Bint(B_zeros_ind) = 0;
XRD = Bint > 0;

clear voxels_with_zero_neighbors B_zeros_ind


%% Crop data
% CT = ctGBs{N}(:,:,cropTopCT:cropBotCT);
CT = ctGBs{N}; CT(:,:,1:cropTopCT) = 0; CT(:,:,cropBotCT:end) = 0;
% XRD = XRD(:,:,cropTopXR:cropBotXR);
XRD(:,:,1:cropTopXR) = 0; XRD(:,:,cropBotXR:end) = 0;

% Convert to uint8 for imreg
XRD = uint8(XRD)*255;
CT = uint8(CT)*255;


%% Do registration
[optimizer,metric] = imregconfig('monomodal');
optimizer.MaximumIterations = maxIt;

% Options:
%   - rigid:      Translation, Rotation
%   - similarity: Translation, Rotation, Scale
%   - affine:     Translation, Rotation, Scale, Shear
tform = imregtform(CT,XRD,'affine',optimizer,metric,...
    'DisplayOptimization',true);

save('~/sp8_2013/ct_rb/MOUT_rb00_reg1_tform.mat','tform')

regCT = imwarp(CT,tform,'nearest','OutputView',imref3d(size(XRD)));

figure; imshowpair(XRD(:,:,250),regCT(:,:,250));
saveas(gcf,'showpairTest_rb00_1.png','png')


%% Apply all four registrations to CT of RB

ctRegRaw = cell(4,1);
for I=1:length(ctRaw)
    ctRegRaw{I} = imwarp(ctRaw{I},tform{I},'OutputView',imref3d(size(xrd3Ds{I})));
end


