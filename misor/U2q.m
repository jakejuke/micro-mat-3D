function q = U2q(U)
%U2Q Summary of this function goes here
%   Detailed explanation goes here

w = sqrt(1 + U(1,1) + U(2,2) + U(3,3))/2;
x = (U(3,2) - U(2,3))/(4*w);
y = (U(1,3) - U(3,1))/(4*w);
z = (U(2,1) - U(1,2))/(4*w);

q = [w, x, y, z];

end

% public final void set(Matrix4f m1) {
% 	w = Math.sqrt(1.0 + m1.m00 + m1.m11 + m1.m22) / 2.0;
% 	double w4 = (4.0 * w);
% 	x = (m1.m21 - m1.m12) / w4 ;
% 	y = (m1.m02 - m1.m20) / w4 ;
% 	z = (m1.m10 - m1.m01) / w4 ;
% }