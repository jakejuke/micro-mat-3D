%% SP8_2013 FULL SCRIPT

% Needs functions:
%   misorientation.m
%   r2U.m
%   U2r.m
%   epsilon.m
%   ...
%   mymisorientation.m
%   sp8_misohisto.m
%   
% % May need
% addpath /home/jules/Dropbox/matlab_code/
% addpath /home/jules/Dropbox/matlab_code/soeren/
% addpath /home/jules/Dropbox/matlab_code/dake/
% addpath /home/jules/Dropbox/matlab_code/99_PlotSkript/
% addpath /home/jules/Dropbox/matlab_code/SubAxis/

clear; %close all; %clc
% load('/home/jules/Dropbox/00_RubberPaper/matlab/MOUT_rb_qtrack.mat')


%% Initialize variables
rootname = 'bh';
maxR = sqrt(2)-1;
% vsl = 5; % voxel side length in microns
% set some cuts
ovlpCuts = [.75 .15];   % quick track fraction of ovlp limits
misoCuts = [7 1.5];     % quick track misori. limits in degrees
a = who;                % Save variable names so they can be used later


%% Get 3D matrices with unique grain numbers
% uigetfile with multiple file select
if exist('fullGTs','var')
    display('Skipping loading of matrices')
else
    % cd('~/sp8_2012/matlab/')
    cd('~/Desktop/')
    [filename, pathname, ~] = uigetfile('*.*', ...
        'Select 3D.mat files', 'MultiSelect', 'on');
    if ischar(filename)
        error('You must select at least two files (two timesteps) to analyze.')
    else
        filenames = transpose(filename);
    end
    cd(pathname); clear filename
    [full3Ds, fullCPs, fullGTs] = sp8_load3Dmats(filenames);
end


%% Display values of user variables
eval(['diary ' rootname '_analyze.log'])
display(date)
display(mfilename('fullpath'))
display(' '); display('User input variables are: ')
for I=1:length(a)
    display([a{I} ' = ' num2str(eval(a{I}))])
end


%% Clean and find surface grains
% cleans 3D data, e.g., fills holes and removes isolated voxels
% also determines: centroid, volume and grainsize
if exist('cleaned','var') && cleaned
    display('Skipping cleaning')
else
    % clean
    [full3Ds, fullGTs] = sp8_cleandata(full3Ds, fullGTs);
    % and detect surface grains
    fullGTs = sp8_surfgraindetect(full3Ds,fullGTs);
    cleaned = true;
end


%% Register 3D matrices
% (Maybe I should run clean after this registration to remove isolated
% voxels, if any...)
if exist('reg3Ds','var')
    display('Skipping registering')
else
    tform = cell(length(fullGTs),1); reg3Ds = cell(length(fullGTs),1);
    reg3Ds{1} = full3Ds{1};
    % Register (spacially) all timesteps
    for I = 2:length(fullGTs)
        [tform{I}, reg3Ds{I}] = sp8_register3D(reg3Ds{I-1},full3Ds{I});
    end
    save(['MOUT_' rootname 'All_reg.mat'])
end


%% Apply spatial transformation to the grain orientations
if sum(fullGTs(end).orient(1,:) == fullGTs(end).old(1,2:4)) == 0
    display('Spatial registration already applied to orientations')
else
    %
    for I=2:length(fullGTs)
        T = tform{I}.T(1:3,1:3);
        % registers grain orientations and applies cubic symetry operations
        fullGTs(I) = sp8_registerGT(fullGTs(I), T);
    end
end


%% Quick check if Rod. vectors are in fundamental zone
for I=1:length(fullGTs)
    if any(max(abs(fullGTs(I).orient)) > maxR)
        display(['WARNING: ' fullGTs(I).timestep ...
            ' has orientations outside fund. zone'])
    end
end


%% quick track
if exist('ovlpMat','var')
    [tkGTs, tkMat, ovlpMat] = sp8_quicktrack(reg3Ds,fullGTs,...
        'ovlpCuts',ovlpCuts,'misoCuts',misoCuts,'ovlpMat',ovlpMat);
else
    [tkGTs, tkMat, ovlpMat] = sp8_quicktrack(reg3Ds,fullGTs,...
        'ovlpCuts',ovlpCuts,'misoCuts',misoCuts);
end


%% clean up multiple matches during quicktrack
for I=2:length(mtkGTs)
    display(mtkGTs(I).timestep)
    mtkGTs(I) = sp8_qtclean(mtkGTs(I));
end

% save(['MOUT_' rootname 'All_qtrack.mat']);
% 
% diary OFF
% exit


%% After manual tracking, can relabel matices and tables with this function
[new3Ds, newGTs, utk3Ds, utkGTs] = sp8_relabelmats(full3Ds, (m)tkGTs);


% %% Save png's
% for I=1:length(fullGTs)
%     sp8_mat2png(full3Ds{I},fullGTs(1),'targetDir',fullGTs(I).timestep,...
%         'prefix',fullGTs(I).timestep);
% end
% 
% 
% %% Find grains that were given the same track label
% % uniqueLabels = unique(regNewGTs(2).tracklabels(isfinite(regNewGTs(2).tracklabels)));
% % uniqueLabels(histc(regNewGTs(2).tracklabels(isfinite(regNewGTs(2).tracklabels)),uniqueLabels)>1)
% 
% 
% %% TEMP, gets original orientations
% for I=1:length(fullGTs)
%     fullGTs(I).orient = fullGTs(I).old(:,2:4);
% end
% 
% 
% %% TEMP, replace orientations with trackregorient
% for I=1:length(fullGTs)
%     fullGTs(I).orient = tkGTs(I).tkregorient;
% end



