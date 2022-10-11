function newGTs = sp8_shrinkGT(fullGTs,varargin)
%SP8_SHRINKGT Removes extra fields from a grain table
%
%   newGTs = sp8_shrinkGT(fullGTs) removes all fields from fullGTs except
%   for: 'timestep','old','labels','orient','centroid','volume' & 'gradius'
%
%   newGTs = sp8_shrinkGT(fullGTs,'F2Keep',{'field1',...}) lets the user
%   define which fields to keep.
%   
%   
%   Jules Dake
%   Uni Ulm, Oct 2014
%      


%% Parse input variables

p = inputParser;

defaultF2Keep = {'timestep',...
                 'old',...
                 'labels',...
                 'orient',...
                 'centroid',...
                 'volume',...
                 'gradius'};

addRequired(p,'fullGTs',@isstruct);
addParameter(p,'F2Keep',defaultF2Keep,@iscell);

parse(p,fullGTs,varargin{:});

f2keep = p.Results.F2Keep;


%% Remove fields from grain tables

f = fieldnames(fullGTs);
f2remove = f(~ismember(f,f2keep));
newGTs = rmfield(fullGTs,[f2remove]);


end


