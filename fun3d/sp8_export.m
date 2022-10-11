function sp8_export(full3D,fullGT,varargin)
%sp8_export Exports a given timestep to a text file
%
%   sp8_export(full3D,fullGT) exports for a given timestep two text files:
%   one with linear indices and grain labels, and the second with
%   orientations for each label.
%   Options: 'PathName', 'BaseName', 'Completeness'
%
%
%   Jules Dake
%   Uni Ulm, 30 Apr 2015
%


%% Parse input variables
p = inputParser;

addRequired(p,'full3D',@isnumeric);
addRequired(p,'fullGT',@isstruct);

def_pathname = pwd;
addParameter(p,'PathName',def_pathname,@ischar);

def_basename = 'default';
addParameter(p,'BaseName',def_basename,@ischar);

def_completeness = [];
addParameter(p,'Completeness',def_completeness);

parse(p,full3D,fullGT,varargin{:});

pathname = p.Results.PathName;
basename = p.Results.BaseName;
fullCP = p.Results.Completeness;


%% Define some variables

if strcmpi(basename,'default') && ischar(fullGT.timestep)
    basename = fullGT.timestep;
end

txt3D = [basename '_3D.txt'];
txtOrient = [basename '_Orient.txt'];
% txtInfo = [basename '_info.txt'];


%% Write txt files

% save linear index and grain label in one variable
B = uint32(zeros(nnz(full3D),3));
B(:,1) = find(full3D>0);
B(:,2) = full3D(B(:,1));
if ~isempty(fullCP)
    B(:,3) = fullCP(B(:,1));
end
% write this variable
fid1 = fopen([pathname '/' txt3D],'w');
fprintf(fid1,'%d %d %d\n',B');
fclose(fid1);

% combine grain labels and orientations into table
orientationTable = [fullGT.labels fullGT.orient];
% write this table
fid2 = fopen([pathname '/' txtOrient],'w');
fprintf(fid2,'%d %f %f %f\n',orientationTable');
fclose(fid2);

end

