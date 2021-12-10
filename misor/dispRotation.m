function dispRotation(U1,varargin)
%dispRotation 
%   
%   dispRotation(U1) shows how the rotation matrix U1 transforms
%   the reference coordinate system by applying U1 to the vertices of a
%   reference cube.
%   
%   This assumes:
%       - matrix products computed by post-multiplication, e.g., M = A'*B
%       - right-handed coordinate system (right-handed rotation)
%       - rotation matrix describes rotation from reference system to
%         current/rotated system (active rotation)
%   
%   
%   Jules Dake
%   12 Nov 2014, Uni Ulm
%   


%% Parse input variables
p = inputParser;

addRequired(p,'U1',@isnumeric);

defaultColor = [1 .7 .7; .7 1 .7; .7 .7 1]; %[0.4 0.4 0.4];
addParameter(p,'Color',defaultColor,@isnumeric);
defaultReference = eye(3);
addParameter(p,'Reference',defaultReference,@isnumeric);

parse(p,U1,varargin{:});
defColor = p.Results.Color;
Uref =p.Results.Reference;

% length of coordinate system axes
len = 1;
% origin of coordinate system axes
org = [0 0 0];

figure
axis equal
xlim([-1 1]); ylim([-1 1]); zlim([-1 1])
view(120,20) % view(-105,-23) % freaky view!

plotAxes3D(len,'origin',org,'Orientation',U1);
plotAxes3D(len,'origin',org,'Color',defColor,'Orientation',Uref);


% % plot rotation axis
% r = U2r(U1); % ----> check this function for correctness!
% % % old way of normalizing r
% % [~,n] = mymisorientation([0 0 0],r);
% n = r/norm(r);
% % double length of unit vector n (so it will be as long as other vectors)
% n2 = n*2 + org;
% % mArrow3(org,n2,'color','k');
% mArrow3([0 0 0],n,'color','k');


end
