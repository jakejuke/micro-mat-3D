function B = sp8_gbextract2D(A)
%SP8_GBEXTRACT This function extracts the boundary voxels from a 2D matrix
%   Looks at every voxel in a 2D matrix. If all four of the voxel's
%   neighbors have the same orientation (label number), that voxel is
%   deleted because it is an interior voxel. If not, it remains as a
%   boundary voxel.
%   
%   EXAMPLE:
%       grainBoundaryVoxels = sp8_gbextract(full3D);
%   
%   INPUT:
%       A - 2D grain matrix
%   
%   OUTPUT:
%       B - 2D matrix with just the boundary voxels of matrix A
%   
%   
%   Jules Dake, Uni Ulm
%   Sept 2014
%   


% Pad matrix A with zeros (in case grain touches an edge of reconstructed
% volume)
A = padarray(A, [1 1]);
% B stores grain boundaries of A
B = uint16(zeros(size(A)));

[L,M] = size(A);
L = L - 1; M = M - 1;

for c=1:M
    for r=1:L
        if A(r,c) ~= A(r+1,c) ...
                || A(r,c) ~= A(r,c+1)  % Is a boundary voxel
            B(r,c) = A(r,c);
        end
        if A(r,c) ~= A(r+1,c)
            B(r+1,c) = A(r+1,c);
        end
        if A(r,c) ~= A(r,c+1)
            B(r,c+1) = A(r,c+1);
        end
    end
end

% Remove extra zeros from padding above
B = B(2:end-1,2:end-1);

end
