function voxellist = sp8_gbVoxelList(A,varargin)
%SP8_GBVOXELLIST gets information on the neighborhood of boundary voxels
%   
%   voxellist = SP8_GBVOXELLIST(A) finds all boundary voxels and returns a
%   voxel list with 9 columns for the 3D matrix 'A'. The columns are
%       c1: index of boundary voxel
%       c2: grain label of voxel
%       c3-c8: labels of six neighboring voxels
%       c9: number of unique neighbors
%   
%   Options
%   -------
%       'boundaryCons' - string; either 'periodic' or 'nonPeriodic'
%                      - option 'periodic' is NOT working yet!
%       'gbMat' - 3D matrix, output of sp8_gbextract.m
%
%   
%   Jules Dake
%   Uni Ulm, 17 Oct 2014
%

% c1: index, c2: grain number of voxel, c3 - c8: grain numbers of
% neighboring voxels:
%   c3(I) = A(r+1,c,z)
%   c4(I) = A(r-1,c,z)
%   c5(I) = A(r,c+1,z)
%   c6(I) = A(r,c-1,z)
%   c7(I) = A(r,c,z+1)
%   c8(I) = A(r,c,z-1)
% c9 number of unique neighbors

%% Parse input variables
p = inputParser;

addRequired(p,'full3D',@isnumeric);

defaultBoundaryCons = 'nonPeriodic';
addParameter(p,'boundaryCons',defaultBoundaryCons,@ischar);
defaultGBMat = NaN;
addParameter(p,'gbMat',defaultGBMat,@isnumeric);

parse(p,A,varargin{:});

boundaryCons  = p.Results.boundaryCons;
gbMat = p.Results.gbMat;


%% Build voxel list
% Get boundary voxels if not given by the user
if isnan(gbMat)
    gbMat = sp8_gbextract(A);
end

B = gbMat;

if strcmpi(boundaryCons,'nonPeriodic')
    
    % Pad matrices by one -- this is important if a boundary voxel is at
    % the very edge of the simulation cell
    A = padarray(A, [1 1 1]);
    B = padarray(B, [1 1 1]);
    
    c1 = find(B>0);
    c2 = nan(length(c1),1);
    c3 = nan(length(c1),1);
    c4 = nan(length(c1),1);
    c5 = nan(length(c1),1);
    c6 = nan(length(c1),1);
    c7 = nan(length(c1),1);
    c8 = nan(length(c1),1);
    c9 = nan(length(c1),1);
    
    parfor I=1:size(c1,1)
        
        [r,c,z] = ind2sub(size(B),c1(I,1));
        
        gnum = A(r,c,z);
        c2(I) = gnum;
        
        if A(r+1,c,z) ~= gnum
            c3(I) = A(r+1,c,z);
        end
        if A(r-1,c,z) ~= gnum
            c4(I) = A(r-1,c,z);
        end
        if A(r,c+1,z) ~= gnum
            c5(I) = A(r,c+1,z);
        end
        if A(r,c-1,z) ~= gnum
            c6(I) = A(r,c-1,z);
        end
        if A(r,c,z+1) ~= gnum
            c7(I) = A(r,c,z+1);
        end
        if A(r,c,z-1) ~= gnum
            c8(I) = A(r,c,z-1);
        end
        
        ta = [c3(I) c4(I) c5(I) c6(I) c7(I) c8(I)]; 
        c9(I) = numel(unique(ta(isfinite(ta))));
        
    end
    
    % fix index values in c1 (from padarray above)
    c1 = find(gbMat > 0);
    % c1: index, c2: grain number of voxel, c3 - c8: grain numbers of
    % neighboring voxels, c9: number of unique neighbors
    voxellist = [c1 c2 c3 c4 c5 c6 c7 c8 c9];
    
elseif strcmpi(boundaryCons,'Periodic')
    error('Option ''Periodic'' not programmed yet')
else
    error('''boundaryCons'' option only takes ''periodic'' or ''nonPeriodic''')
end

end

