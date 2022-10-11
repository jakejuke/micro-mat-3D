function r = U2r(U)
%U2r Convert a rotation matrix to a Rodrigues vector
%
%   r = U2r(U), where U is a 3x3 orthogonal rotation matrix
%
%   Based on code from S. Schmidt (DTU)
%   It appears he used A. Morawiec's book "Orientations and Rotations" as
%   his source (see pg. 22)
%   
%   Modified by J. Dake to keep the sign of the Rodrigues vector consistent
%   with the following definitions:
%       1. right-handed coordinate systems
%       2. right-handed rotation is positive
%       3. rotation takes ref. coordinate system to crystal/sample system,
%          i.e., active rotation
%       4. use postmultiplication of matrices (to match existing
%          conventions in 3DXRD community)
%
%   Jules Dake
%   Uni Ulm, 13 Sep 2015
%   Updated on: 21 Jan 2016

% From Soeren's U2r.m %%
% rSoeren = [(U(2,3)-U(3,2))/(1+U(1,1)+U(2,2)+U(3,3)) ...
%             (U(3,1)-U(1,3))/(1+U(1,1)+U(2,2)+U(3,3)) ...
%             (U(1,2)-U(2,1))/(1+U(1,1)+U(2,2)+U(3,3))];
%
% Also the same in:
% Engler2010 %%
% theta = acosd((U(1,1) + U(2,2) + U(3,3) - 1)/2);
% nEngler = [(U(2,3)-U(3,2))/(2*sind(theta)), ...
%            (U(3,1)-U(1,3))/(2*sind(theta)), ...
%            (U(1,2)-U(2,1))/(2*sind(theta))];
% rEngler = nEngler*tand(theta/2);

% Modified version of Soeren Schmidt's original U2r.m code
r = [(U(2,3)-U(3,2))/(1+U(1,1)+U(2,2)+U(3,3)) ...
     (U(3,1)-U(1,3))/(1+U(1,1)+U(2,2)+U(3,3)) ...
     (U(1,2)-U(2,1))/(1+U(1,1)+U(2,2)+U(3,3))];
 
end
