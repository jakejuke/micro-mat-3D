function [sim3Ds, simGTs] = import_pfsim(orimap)
%pf_sim_import Summary of this function goes here
%   Detailed explanation goes here
%   
%   Add vargin with:
%       - simsteps
%       - path to orimap
%       - path to files...
%

%% Import orientations

U_list = load(orimap);

% Each row of orimap represents one grain
numGrains = size(U_list,1);
% Assumes grains are numbered from 1 to max number of grains
grainIDs = 1:numGrains;
rodList = zeros(numGrains,3);

for I=1:numGrains
    % Create 3x3 U matrix from each row
    U =  [ U_list(I,1:3); ...
           U_list(I,4:6); ...
           U_list(I,7:9) ];
    % Convert to Rodrigues vector
    rodriguesVector = U2r(U);
    % Put Rodrigues vector in fundamental zone
    [~, ~, ~, rodList(I,:)] = mymisorientation([0 0 0], rodriguesVector);
    %%%%%%%%%%
    %  BUG!  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This misorientation between the Rodrigues vectors before and after  %
    % putting it in the fundamental zone is not zero!                     %
    % E.g., mymisorientation(rodList(1,:),rodriguesVector) != 0, bei I=1  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end



%% Saves current directory asks user to select data file(s)

wd = pwd;

% To speed up selection, you can hard code to a folder with pf sim output
cd('/Users/jules/Library/Mobile Documents/com~apple~CloudDocs/Downloads/toJules')

[filename, pathname, filterindex] = uigetfile('*.*', ...
    'Select simulation steps to import', 'MultiSelect', 'on');
if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
       cd(wd)
       return
elseif ischar(filename)
    filenames{1} = filename;
    fprintf('\nOnly one file selected!\n\n')
else
    filenames = transpose(filename);
    filenames = sort(filenames);
end
cd(pathname); clear filename

simGTs = initBasicGTs();

% load 3D simdata
sim3Ds = cell(length(filenames),1);
for I=1:length(filenames)
    [~,varname] = fileparts(filenames{I});
    % timestep is the file name
    simGTs(I,1).timestep = varname;
    % load 3D mat into cell 'sim3Ds'
    tempS = load(filenames{I});
    eval(['temp3D = tempS.' varname ';'])
    sim3Ds{I} = sp8_fliprotsim(uint16(temp3D));
end

cd(wd)


% simGTs = initGTs();
% 
% for I=1:length(sim3Ds)
%     s = regionprops(sim3Ds{I});
%     % simGT_bh400(I).labels = (1:length(simGT_bh400(1).labels))';
%     simGTs(I,1).timestep = timesteps{I};
%     simGTs(I,1).labels = fullGT.labels(vertcat(s.Area)>0);
%     simGTs(I,1).old = fullGT.old(vertcat(s.Area)>0,:);
%     simGTs(I,1).orient = fullGT.orient(vertcat(s.Area)>0,:);
%     areas = vertcat(s.Area);
%     simGTs(I,1).volume = areas(vertcat(s.Area)>0);
%     simGTs(I,1).gradius = ((3*simGTs(I).volume)/(4*pi)).^(1/3);
% end


end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%
function simGTs = initGTs()
% Initializes the grain statistics (gStats) matrix

% fields are:
fd00 = 'timestep';
fd0 = 'old';
fd1 = 'labels';
fd2 = 'orient';
fd3 = 'centroid';
fd4 = 'volume';
fd5 = 'gradius';

simGTs = struct(fd00,{},fd0,{},fd1,{},fd2,{},fd3,{},fd4,{},fd5,{});

end

function simGTs = initBasicGTs()
% Initializes the grain statistics (gStats) matrix

% fields are:
fd00 = 'timestep';
fd0 = 'old';
fd1 = 'labels';
fd2 = 'orient';
fd3 = 'time';

simGTs = struct(fd00,{},fd0,{},fd1,{},fd2,{},fd3,{});

end
