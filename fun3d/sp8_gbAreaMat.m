function [bMat,fullGT] = sp8_gbAreaMat(voxlist,fullGT)
%SP8_GBAREAMAT find approximate boundary areas between grains
%   
%   [bMat,fullGT] = SP8_GBAREAMAT(voxlist,fullGT) calculates the boundary
%   voxels between grains using the voxlist from sp8_gbVoxelList.m. The
%   results are then added to the grain table, fullGT.
%   
%   bMat has dimensions of (N+1,N+1) if there are N grains in the sample
%   for the given timestep. This is because index zero does not work in
%   Matlab. Column 1 is thus the boundary area of the grain in row # with
%   the surface. Row 1 of bMat contains the total boundary area for each
%   grain given by the column index + 1 (same is stored in fullGT.gbArea).
%   
%   The sum of the individual entries in each row/column from 2:end will be
%   larger than the value of total area in row 1, because some voxels that
%   have boundaries with more than one grain (e.g. near triple junctions)
%   will be counted twice.
%
%   
%   Jules Dake
%   19 Oct 2014
%   


%% Check grains in sample
% grains labels of grains in sample
grains = unique(voxlist(:,2));
grains_in_GT = fullGT.labels(isfinite(fullGT.labels));
if any(grains - grains_in_GT)
    warning(['In timestep: ' fullGT.timestep])
    warning('Disagreement between grains in grain table and voxel list')
end

% Preallocate boundary matrix
%-- Bug fix --
% bMat = nan(max(grains(:)) + 1);
% Line above causes problems if the grain with the large label disappears...
bMat = nan(length(fullGT.labels) + 1);
%-- End bug fix --


%% Calculate boundary areas
for I=1:length(grains)
    % 3:8 store the labels of the neighboring voxels
    sublist = voxlist(voxlist(:,2)==grains(I),3:8);
    % save total GB area in row 1 (which is actually row zero)
    bMat(1,grains(I) + 1) = length(sublist);
    % neighbors of grains(I)
    nearestN = unique(sublist(isfinite(sublist)));
    
    % now look at each neighbor of grains(I) and count voxels in contact
    for J=1:length(nearestN)
        bMat(grains(I) + 1,nearestN(J) + 1) = ...
            nnz(any(sublist == nearestN(J),2));
    end
end


%% Update fullGT
fullGT.gbArea = bMat(1,2:end)';
fullGT.gbMat = bMat;


end
