function plotMackenzie(varargin)
%plotMackenzie plot normalized (area = 1) Mackenzie distribution
%
%   plotMackenzie(varargin) - vararging are standard 'plot' options
%
%
%   Mingyan Wang
%   Uni Ulm, 16 Oct 2014
%   *Modified by Jules Dake on 18 Jan 2015
%  

x1=.1:0.1:45;
y1 = 2/15*(1-cos(x1/180*pi));

x2=45:0.1:60;
y2 = 2/15*(3*(sqrt(2)-1)*sin(x2/180*pi)-2*(1-cos(x2/180*pi)));

x3=60:0.1:60.72;
y3 = 2/15*((3*(sqrt(2)-1)+4/sqrt(3))*sin(x3/180*pi)-6*(1-cos(x3/180*pi)));


y4=[];
for x4=60.72:0.1:62.8
    tx = double((sqrt(2)-1)/sqrt(1-(sqrt(2)-1)^2*(cot(x4/180*pi/2))^2));
    ty = double((sqrt(2)-1)^2/sqrt(3-(cot(x4/180*pi/2))^2));
    y4(end+1) =2/15*((3*(sqrt(2)-1)+4/sqrt(3))*sin(x4/180*pi)-6*(1-cos(x4/180*pi)))...
        -(8/5/pi)*sin(x4/180*pi)*(2*(sqrt(2)-1)*acos(tx*cot(x4/180*pi/2))+1/sqrt(3)*acos(ty*cot(x4/180*pi/2)))...
        +(8/5/pi)*(1-cos(x4/180*pi))*(2*acos((sqrt(2)+1)*tx/sqrt(2))+acos((sqrt(2)+1)*ty/sqrt(2)));
end
x4=60.72:0.1:62.8;

x = [x1 x2 x3 x4];
y = real([y1 y2 y3 y4]);
plot(x,y,varargin{:})

end