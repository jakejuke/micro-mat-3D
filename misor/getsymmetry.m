function G = getsymmetry(symmetry)
%getsymmetry Returns crystallographic equivalent representations for cubic,
%hexagonal and orthorhombic symmetries
%
%   G = getsymmetry(symmetry) returns 3-dimensional matrix G with symmetry
%   operations for input arguments: 'cubic', 'hexagonal' or 'orthorhombic'
%   
%   Based on Engler and Randle's book (Introduction to Texture Analysis:
%   Macrotexture, Microtexture, and Orientation Mapping) from 2010
%   
%   Jules Dake
%   Uni Ulm, 13 Sep 2015
%

if strcmpi(symmetry,'cubic')
    % 24 cubic symmetries, from S. Schmidt checked with Engler2010
    G( 1,:,:) = [ 1  0  0;  0  1  0;  0  0  1];
    G( 2,:,:) = [ 0 -1  0;  1  0  0;  0  0  1];
    G( 3,:,:) = [-1  0  0;  0 -1  0;  0  0  1];
    G( 4,:,:) = [ 0  1  0; -1  0  0;  0  0  1];
    G( 5,:,:) = [ 1  0  0;  0  0 -1;  0  1  0];
    G( 6,:,:) = [ 1  0  0;  0 -1  0;  0  0 -1];
    G( 7,:,:) = [ 1  0  0;  0  0  1;  0 -1  0];
    G( 8,:,:) = [ 0  0  1;  0  1  0; -1  0  0];
    G( 9,:,:) = [-1  0  0;  0  1  0;  0  0 -1];
    G(10,:,:) = [ 0  0 -1;  0  1  0;  1  0  0];
    G(11,:,:) = [ 0  0  1;  1  0  0;  0  1  0];
    G(12,:,:) = [ 0  1  0;  0  0  1;  1  0  0];
    G(13,:,:) = [ 0 -1  0;  0  0 -1;  1  0  0];
    G(14,:,:) = [ 0  0  1; -1  0  0;  0 -1  0];
    G(15,:,:) = [ 0 -1  0;  0  0  1; -1  0  0];
    G(16,:,:) = [ 0  0 -1; -1  0  0;  0  1  0];
    G(17,:,:) = [ 0  0 -1;  1  0  0;  0 -1  0];
    G(18,:,:) = [ 0  1  0;  0  0 -1; -1  0  0];
    G(19,:,:) = [ 0  1  0;  1  0  0;  0  0 -1];
    G(20,:,:) = [ 0 -1  0; -1  0  0;  0  0 -1];
    G(21,:,:) = [-1  0  0;  0  0  1;  0  1  0];
    G(22,:,:) = [-1  0  0;  0  0 -1;  0 -1  0];
    G(23,:,:) = [ 0  0  1;  0 -1  0;  1  0  0];
    G(24,:,:) = [ 0  0 -1;  0 -1  0; -1  0  0];
    
elseif strcmpi(symmetry,'hexagonal')
    % 12 hexagonal symmetries
    G( 1,:,:) = [ 1  0  0;  0  1  0;  0  0  1];
    error('Not finished programming hex. symmetry!')
    
elseif strcmpi(symmetry,'orthorhombic')
    % 4 orthorhombic symmetries
    G( 1,:,:) = [ 1  0  0;  0  1  0;  0  0  1];
    G( 2,:,:) = [ 1  0  0;  0 -1  0;  0  0 -1];
    G( 3,:,:) = [-1  0  0;  0  1  0;  0  0 -1];
    G( 4,:,:) = [-1  0  0;  0 -1  0;  0  0  1];
else
    error('Valid input arguments are: cubic, hexagonal or orthorhombic')
end

end

