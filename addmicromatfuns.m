function addmicromatfuns(varargin)
%addmicromatfuns Add micro-mat functions to the user's path
%
%   Adds all the follow directories to the user's path
%   
%       'exchange' - Files from Matlab''s File Exchange community
%       'fun3d'    - Functions for 3D analysis and visualization
%       'misc'     - Some potentially useful miscellaneous functions
%       'misor'    - Functions for working with (mis)orientations
%       'xtras'    - Potentially useful code that I did not want to delete
%       
%   Jules Dake
%   Uni Ulm, 20 Oct 2022


%% Parse input variables
p = inputParser;

defaultLibs = 'all';
addParameter(p,'libs2load',defaultLibs,@ischar);

%%% NOTE %%%
%   I wanted to also let users select which directories to add to their
%   path, but Matlab's uigetdir does not allow multiple select, so I just
%   hardcoded all the directories.

if nargin ~= 0
    warning('Currently only programmed to add all default directories')
end


%% Add directories to path
baseDir = pwd;

codeDirs(1).name = 'exchange';
codeDirs(1).path = strcat(baseDir,filesep,codeDirs(1).name);
codeDirs(1).info = 'Files from Matlab''s File Exchange community';

codeDirs(2).name = 'fun3d';
codeDirs(2).path = strcat(baseDir,filesep,codeDirs(2).name);
codeDirs(2).info = 'Functions for 3D analysis and visualization';

codeDirs(3).name = 'misc';
codeDirs(3).path = strcat(baseDir,filesep,codeDirs(3).name);
codeDirs(3).info = 'Some potentially useful miscellaneous functions';

codeDirs(4).name = 'misor';
codeDirs(4).path = strcat(baseDir,filesep,codeDirs(4).name);
codeDirs(4).info = 'Functions for working with (mis)orientations';

codeDirs(5).name = 'xtras';
codeDirs(5).path = strcat(baseDir,filesep,codeDirs(5).name);
codeDirs(5).info = 'Potentially useful code that I did not want to delete';

for R = 1:length(codeDirs)
    addpath(codeDirs(R).path)
end

end