function sp8_export3D(full3D,fullGT,varargin)
%sp8_export Exports a given timestep to a text file
%
%   sp8_export3D(full3D,fullGT) exports reconstructed 3DXRD data to text
%   file. Seven columns: grainID; row; column; layer; rod1; rod2; rod3.
%
%   Options: 'PathName', 'BaseName'
%
%
%   Jules Dake
%   Uni Ulm, 14 Sep 2016
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


%% Write txt files

% save linear index and grain labels
bigMat = zeros( nnz(full3D), 8 );
linInd = find( full3D > 0 );
grainLabels = full3D( linInd );
[I, J, K] = ind2sub( size(full3D), linInd );

bigMat(:,1) = grainLabels;
bigMat(:,2) = I;
bigMat(:,3) = J;
bigMat(:,4) = K;

tic
for loopI = 1:length(fullGT.labels)
    if isfinite(fullGT.labels(loopI))
        fprintf('Grain: %d\n',fullGT.labels(loopI))
        bigMat( bigMat(:,1) == fullGT.labels(loopI), 5) = fullGT.orient(loopI,1);
        bigMat( bigMat(:,1) == fullGT.labels(loopI), 6) = fullGT.orient(loopI,2);
        bigMat( bigMat(:,1) == fullGT.labels(loopI), 7) = fullGT.orient(loopI,3);
    end
end
toc

completeness = fullCP( linInd );
bigMat(:,end) = completeness;

%% write this variable
display('writing text file')
tic
fid1 = fopen([pathname '/' txt3D],'w');
fprintf(fid1,'grainID\trow\tcolumn\tlayer\trod1\trod2\trod3\n');
fprintf(fid1,'%d\t%d\t%d\t%d\t%.4f\t%.4f\t%.4f\t%d\n',bigMat');
fclose(fid1);
toc

end

