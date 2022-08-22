function [phi, n, dr] = misor1(U)
%misor1 Returns rotation angle phi, rotation axis n, and Rodrigues vector
%for a given orientation matrix U
%
%   EXAMPLE:
%       [phi, n, dr] = misor1(U)
%
%   By Jules Dake, Uni Ulm, Germany.
%

phi = acosd((U(1,1) + U(2,2) + U(3,3) - 1)/2);
dr = U2r(U);
% phi = 2.*atand(norm(dr)); % should be the same
n = dr/norm(dr);

end
