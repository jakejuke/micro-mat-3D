function [sim3Ds, simGTs] = import_pfsim(orimap)
%import_pfsim imports output of Krill Group phase-field simulations
%
%   The function takes the orimap and asks the user to input simstep.mat
%   files.
%   
%   Examples
%       [full3Ds, fullGTs] = import_pfsim('path/to/orimap')
%
%   7 Feb 2023  
%   Jules Dake, Uni Ulm
%

%   Could add vargin with:
%       - simsteps
%       - path to orimap
%       - path to files...
%

%% Import orientations

clear
orimap = '/Users/jules/Documents/Matlab/micro-mat-3D/data/sim_import_test/orimap';
U_list = load(orimap);

% Each row of orimap represents one grain
numGrains = size(U_list,1);
% Assumes grains are numbered from 1 to max number of grains
grainIDs = [1:numGrains]';
% List for saving Rodrigues vectors
rodList = zeros(numGrains,3);

% Convert all lines of U_list to Rodrigues vectors
for I=1:numGrains
    
    % Create 3x3 U matrix from each row
    U =  [ U_list(I,1:3); ...
           U_list(I,4:6); ...
           U_list(I,7:9) ];

    %%%%%%%%%%%%%%%%%%%%%%
    %  BUG! and Bug fix  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This misorientation between the Rodrigues vectors before and after  %
    % putting it in the fundamental zone is not zero!                     %
    % E.g., mymisorientation(rodList(1,:),rodriguesVector) != 0, bei I=1  %
    % To fix this, I added the applysymm function.                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get minimum U (relative to ref. coordinate system) for cubic symm.
    U_min = applysymm(U,'cubic');

    % Convert to Rodrigues vector
    rodVector = U2r(U_min);
    % Put Rodrigues vector in fundamental zone
    [~, ~, ~, rodList(I,:)] = mymisorientation([0 0 0], rodVector);

end


%% Get grain matrices from user

wd = pwd;

% To speed up selection, you can hard code to a folder with pf sim output
cd('/Users/jules/Documents/Matlab/micro-mat-3D/data/sim_import_test')

% Ask user to select 3D data files
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

    %filenames = sort(filenames);
    %%%%%%%%%%%%%%%%%%%%%%
    %  BUG! and Bug fix  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % File names are loaded in order that they are clicked. Sorting does
    % not work either (e.g., sorting produces: 0, 1000, 200, 800). To get
    % around this, I wrote the for loop below that extracts the last number
    % in each file name -- this is typically the sim step.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

cd(pathname); clear filename


% Sort files by the numbers at the end (sim steps)
file_nums = nan(length(filenames),1);
for I=1:length(filenames)
    nums_in_filenames = regexp(filenames{I},'\d*','Match');
    num_end_of_file = str2double(nums_in_filenames{end});
    file_nums(I) = num_end_of_file;
end

[~, ind] = sort(file_nums);

% Make a basic Grain Table
simGTs = initBasicGTs();
% Load 3D data matrices
sim3Ds = cell(length(filenames),1);
for I=1:length(filenames)
    % Important to use ind(I) to get sorting correct!
    [~,varname] = fileparts(filenames{ind(I)});
    % Load 3D mat into cell 'sim3Ds'
    tempS = load(filenames{ind(I)});
    eval(['temp3D = tempS.' varname ';'])
    sim3Ds{I} = sp8_fliprotsim(uint16(temp3D));
    % The timestep is just the file name
    simGTs(I,1).timestep = varname;
    simGTs(I,1).time = file_nums(ind(I));
end

cd(wd)


%% Set up Grain Tables

for I=1:length(sim3Ds)
    
    % Initialize values for each timestep
    simGTs(I,1).labels = nan(numGrains,1);
    simGTs(I,1).orient = nan(numGrains,3);
    simGTs(I,1).centroid = nan(numGrains,3);
    simGTs(I,1).volume = nan(numGrains,1);
    simGTs(I,1).gradius = nan(numGrains,1);
    
    % Get stats for all grains still existing for each timestep
    s = regionprops(sim3Ds{I});
    activeIDs = vertcat(s.Area) > 0;

    % Save parameters/values for each grain at each timestep
    simGTs(I,1).labels(activeIDs,:) = grainIDs(activeIDs);
    simGTs(I,1).orient(activeIDs,:) = rodList(activeIDs,:);
    simGTs(I,1).old = [simGTs(I).labels, simGTs(I).orient];

    centroids = vertcat(s.Centroid);
    simGTs(I,1).centroid(activeIDs,:) = centroids(activeIDs,:);

    areas = vertcat(s.Area);
    simGTs(I,1).volume(activeIDs,:) = areas(activeIDs,:);
    simGTs(I,1).gradius = ((3*simGTs(I).volume)/(4*pi)).^(1/3);
end


end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%

% %% Do I really even need these?
% %% Maybe I got a bit carried away with initializing variables ...


% Initialize a basic Grain Table
function simGTs = initBasicGTs()

% fields are:
fd00 = 'timestep';
fd0 = 'old';
fd1 = 'labels';
fd2 = 'orient';
fd3 = 'time';

simGTs = struct(fd00,{},fd0,{},fd1,{},fd2,{},fd3,{});

end


% Initialize a Grain Table with more fields
function simGTs = initGTs()

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