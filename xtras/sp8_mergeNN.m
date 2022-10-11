function A = sp8_mergeNN(A,fullGT,misorCut)
%sp8_mergeNN Merges nearest neighbors (after sp8_read) if misorientation is
%            small
%
%   A = sp8_mergeNN(A,fullGT) merges the grains in the 3D matrix A if the
%   orientation between nearest neighbors is less than misorCut.
%   Orientations are stored in the structure fullGT.
%
%   Not the prettiest code I've written. I wrote this in a hurry for Jette
%   ;-)
%
%   Jules Dake
%   Uni Ulm, 18 Nov 2014
%

[r,c,z] = size(A);


%% Loop through 3D matrix and check neighbors of each voxel

for I=1:z-1; for J=1:c-1; for K=1:r-1
    
    if A(K,J,I) > 0
        g1 = A(K,J,I);   % grain1
    
        if A(K+1,J,I) ~= g1 && A(K+1,J,I) > 0
            g2 = A(K+1,J,I); % grain 2
            if (mymisorientation(fullGT.orient(g1,:),fullGT.orient(g2,:)) < misorCut)
                A(A==g2) = g1;
            end
        end
        if A(K,J+1,I) ~= g1 && A(K,J+1,I) > 0
            g2 = A(K,J+1,I);
            if (mymisorientation(fullGT.orient(g1,:),fullGT.orient(g2,:)) < misorCut)
                A(A==g2) = g1;
            end
        end
        if A(K,J,I+1) ~= g1 && A(K,J,I+1) > 0
            g2 = A(K,J,I+1);
            if (mymisorientation(fullGT.orient(g1,:),fullGT.orient(g2,:)) < misorCut)
                A(A==g2) = g1;
            end
        end
    
    end
    
    
end; end; end


end




