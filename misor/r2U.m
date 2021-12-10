function U = r2U(r)
%r2U Take Rodrigues vector to rotation matrix notation
%
%   U = r2U(r) converts the three-component Rodrigues vector r to a 3x3
%   rotation matrix U, where the rows of the orientation matrix are the
%   x,y,z axes of the rotated object. This means a point/vector in the
%   reference frame should be postmultiplied by U.
%
%   Original code from S. Schmidt, DTU
%   It appears he used A. Morawiec's book "Orientations and Rotations"
%   (2004) as his source (see pg. 22)
%
%   Modified by J. Dake, Uni Ulm on 13 Sep 2015 (see comments below)
%   Modifications were needed to keep conversions consistent with
%   definitions, i.e. right-handed rotation, right-handed coordinate
%   systems, from ref. system to crystal/object, and matrix
%   premultiplication
%   
%   Jules Dake
%   Uni Ulm, 13 Sep 2015
%

r2 = r(1)^2+r(2)^2+r(3)^2;
a = 1.-r2;
b = 1./(1.+r2);
c = 2.*b;
r01 = r(1)*r(2);
r02 = r(1)*r(3);
r12 = r(2)*r(3);


U(1,1) = (a+2.*r(1)^2)*b;
U(2,2) = (a+2.*r(2)^2)*b;
U(3,3) = (a+2.*r(3)^2)*b;

U(1,2)=(r01+r(3))*c;
U(2,1)=(r01-r(3))*c;

U(1,3)=(r02-r(2))*c;
U(3,1)=(r02+r(2))*c;

U(2,3)=(r12+r(1))*c;
U(3,2)=(r12-r(1))*c;
  
end
  