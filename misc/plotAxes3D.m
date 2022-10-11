function m = plotAxes3D(a,varargin)
%PLOTAXES3D plots x, y & z axes at the origin
%
%   m = plotAxes3D(a) plots axes in x, y and z from [0,0,0] to [a,0,0] ...
%   using the function mArrow3 from the Matlab Exchange. The default colors
%   are: x - blue, y - red, z - green.
%
%
%   Jules Dake
%   Uni Ulm, 10 Nov 2014
%


%% Parse input variables
p = inputParser;

addRequired(p,'a',@isnumeric);

defOrg = [0, 0, 0];
addParameter(p,'Origin',defOrg,@isnumeric);
defColor = NaN;
addParameter(p,'Color',defColor,@isnumeric);
defaultOrient = eye(3);
addParameter(p,'Orientation',defaultOrient,@isnumeric);

parse(p,a,varargin{:});
org = p.Results.Origin;
axisColor = p.Results.Color;
A = p.Results.Orientation;


%% show x,y,z axes
x = [a, 0, 0]; x = x*A;
y = [0, a, 0]; y = y*A;
z = [0, 0, a]; z = z*A;

% convert org is a column vector, convert to row
if iscolumn(org)
    org = org';
end

if isnan(axisColor)
    mX = mArrow3(org,org+x,'color','r');
    mY = mArrow3(org,org+y,'color','g');
    mZ = mArrow3(org,org+z,'color','b');
elseif length(axisColor(:)) < 9
    mX = mArrow3(org,org+x,'color',axisColor(1:3));
    mY = mArrow3(org,org+y,'color',axisColor(1:3));
    mZ = mArrow3(org,org+z,'color',axisColor(1:3));
else
    mX = mArrow3(org,org+x,'color',axisColor(1:3));
    mY = mArrow3(org,org+y,'color',axisColor(4:6));
    mZ = mArrow3(org,org+z,'color',axisColor(7:9));
end

m = [mX; mY; mZ];

end

