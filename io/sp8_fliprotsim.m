function B = sp8_fliprotsim(A)
%SP8_FLIPROTSIM Rotate and flip the PF simulation output
%
%   Matlab and the phase-field simulation index the 3D volumes differently.
%   This function flips and rotates the output of the simulation to match
%   original (experimental) data in Matlab.
%   
%   Example:
%       new3D = sp8_fliprotsim(full3D);
%
%   Jules Dake
%   Uni Ulm
%

A = rot90(A);
B = flip(A,1);

end

