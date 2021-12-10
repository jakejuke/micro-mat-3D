function U = aa2U_Engler(rotAxis,rotAngle)
%aa2U_Engler calculates a orientation matrix from given axis and angle
%
%   U = aa2U_Engler(rotAxis,rotAngle) following Engler and Randle's book
%   (Introduction to Texture Analysis: Macrotexture, Microtexture, and
%   Orientation Mapping, Second Edition) calculates a 3D rotation matrix U
%   from the given rotAxis and rotAngle (in degrees).
%
%   Jules Dake (with Mingyan Wang)
%   Ulm University, 2 Sep 2015
%

% normalizes rotation axis (in case it is not already normalized)
r = rotAxis/norm(rotAxis);
% could check to see if it is in degrees (something like +2pi)
a = rotAngle;

% From Engler and Randle's book (Introduction to Texture Analysis:
% Macrotexture, Microtexture, and Orientation Mapping, Second Edition),
% section 2.7.1 (Axis/Angle of Rotation) on page 41.
g11 = (1-r(1)^2)*cosd(a)    + r(1)^2;
g12 = r(1)*r(2)*(1-cosd(a)) + r(3)*sind(a);
g13 = r(1)*r(3)*(1-cosd(a)) - r(2)*sind(a);
g21 = r(1)*r(2)*(1-cosd(a)) - r(3)*sind(a);
g22 = (1-r(2)^2)*cosd(a)    + r(2)^2;
g23 = r(2)*r(3)*(1-cosd(a)) + r(1)*sind(a);
g31 = r(1)*r(3)*(1-cosd(a)) + r(2)*sind(a);
g32 = r(2)*r(3)*(1-cosd(a)) - r(1)*sind(a);
g33 = (1-r(3)^2)*cosd(a)    + r(3)^2;

U = [g11, g12, g13;
     g21, g22, g23;
     g31, g32, g33];
 
end
