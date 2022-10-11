function m = sp8_showRotAxis(goi,sub3D,rotA)
%sp8_showRotAxis Add rotation axis through the center of rotating grain
%   
%   m = sp8_showRotAxis(goi,sub3D,rotA) adds a rotation axis defined by the
%   Rodrigues vector rotA through the center of mass of the grain of
%   interest goi, which is in the 3D volume sub3D. In sub3D the region
%   belonging to the grain of interest should have a unique label defined
%   by the integer goi. The function returns the handel m of the newly
%   plotted 3D arrow.
%   *Note: This function requires the function 'mArrow3.m' from Matlab's
%          File Exchange be in the path.
%   
%   Options
%   ----------
%   Future option to add rotation axis at the origin (instead of at grain's
%   center of mass)
%   Color of arrow
%   
%   
%   Jules Dake
%   Uni Ulm, 10 Nov 2014
%   



%% Make line along rotation axis that extends through sub3D

% find center of mass of goi
s = regionprops(sub3D);
r_0 = s(goi).Centroid;

% make a line that definitely extends through the entire sub3D volume
a = max(size(sub3D));
t = -2*a:2*a;
for I=1:length(t)
    r(I,:) = r_0 + t(I)*rotA;
end

% remove positive points outside sub3D
[yMax, xMax, zMax] = size(sub3D);
r(r(:,1)>xMax,:) = []; r(r(:,2)>yMax,:) = []; r(r(:,3)>zMax,:) = [];

% remove negative points => points outside sub3D
r(any(r<0,2),:) = [];



%% Add rotation axis

% m1 = mArrow3([0 0 0],20*rotA,'color','k');
m2 = mArrow3(r(1,:),r(end,:),'color','k');

% m = [m1, m2];
m = m2;


end

