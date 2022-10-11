function B = sp8_gbextract(A)
%SP8_GBEXTRACT This function extracts the boundary voxels from a 3D matrix
%   Looks at every voxel in a 3D matrix. If all six of the voxel's
%   neighbors have the same orientation (label number), that voxel is
%   deleted because it is an interior voxel. If not, it remains as a
%   boundary voxel.
%   
%   EXAMPLE:
%       grainBoundaryVoxels = sp8_gbextract(full3D);
%   
%   INPUT:
%       A - 3D grain matrix
%   
%   OUTPUT:
%       B - 3D matrix with just the boundary voxels of matrix A
%   
%   
%   Jules Dake
%   Uni Ulm, May 2014
%   


% Pad matrix A with zeros (in case grain touches an edge of reconstructed
% volume)
A = padarray(A, [1 1 1]);
% B stores grain boundaries of A
B = uint16(zeros(size(A)));

[L,M,N] = size(A);
L = L - 1; M = M - 1; N = N - 1;

for z=1:N
    for c=1:M
        for r=1:L
            if A(r,c,z) ~= A(r+1,c,z) ...
                    || A(r,c,z) ~= A(r,c+1,z) ...
                    || A(r,c,z) ~= A(r,c,z+1) % Is a boundary voxel
                B(r,c,z) = A(r,c,z);
            end
            if A(r,c,z) ~= A(r+1,c,z)
                B(r+1,c,z) = A(r+1,c,z);
            end
            if A(r,c,z) ~= A(r,c+1,z)
                B(r,c+1,z) = A(r,c+1,z);
            end
            if A(r,c,z) ~= A(r,c,z+1)
                B(r,c,z+1) = A(r,c,z+1);
            end
        end
    end
end

% Remove extra zeros from padding above
B = B(2:end-1,2:end-1,2:end-1);

end
