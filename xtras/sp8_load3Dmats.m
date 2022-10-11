function [full3Ds, fullCPs, fullGTs] = sp8_load3Dmats(filenames)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
%   Used by:
%       sp8_analyze.m
%   
%

% preallocation
full3Ds = cell(length(filenames),1);
fullCPs = cell(length(filenames),1);

% can initialize structure like this
% the order of field names is important, see for loop below
% fullGT data being loaded should be in column form: #label; #r1; #r2; #r3
ifields = {'timestep',{},'old',{},'labels',{},'orient',{}};
fullGTs = struct(ifields{:});
ifields = fields(fullGTs); % gets rid of '{}' used to initialize structure

% My matrices have names like: MatlabOUT_bh430.mat
% In this .mat file there are variables: full3D_bh430, fullCP_bh430
% and fullGT_bh430
for I=1:length(filenames)
    load(filenames{I})
end

for I=1:length(filenames)
    S = who('full3D_*');
    eval(['full3Ds{' num2str(I) '} = ' S{1} ';'])
    eval(['clear ' S{1}])
    
    S = who('fullCP_*');
    eval(['fullCPs{' num2str(I) '} = ' S{1} ';'])
    eval(['clear ' S{1}])
    
    S = who('fullGT_*');
    C = strsplit(S{1},'_');
    eval(['fullGTs(' num2str(I) ',1).' ifields{1} ' = ''' C{end} ''';'])
    eval(['fullGTs(' num2str(I) ',1).' ifields{2} ' = ' S{1} ';'])
    eval(['fullGTs(' num2str(I) ',1).' ifields{3} ' = ' S{1} '(:,1);'])
    eval(['fullGTs(' num2str(I) ',1).' ifields{4} ' = ' S{1} '(:,2:4);'])
    eval(['clear ' S{1}])
end


end

