function plotMackenzie(varargin)
%plotMackenzie plot normalized (area = 1) Mackenzie distribution
%
%   plotMackenzie(varargin) - vararging are standard 'plot' options
%
%
%   Mingyan Wang
%   Uni Ulm, 16 Oct 2014
%   * Modified by Jules Dake on 18 Jan 2015
%   * And again on 1 Jun 2023
%  

step_size = 0.01;

x1=0:step_size:45;
y1 = 2/15*(1-cos(x1/180*pi));

x2=45+step_size:step_size:60;
y2 = 2/15*(3*(sqrt(2)-1)*sin(x2/180*pi)-2*(1-cos(x2/180*pi)));

x3=60+step_size:step_size:60.72;
y3 = 2/15*((3*(sqrt(2)-1)+4/sqrt(3))*sin(x3/180*pi)-6*(1-cos(x3/180*pi)));

x4=60.72+step_size:step_size:62.8;
y4=zeros(1,length(x4));
for idx = 1:length(x4)
    x_for = x4(idx);
    tx = double((sqrt(2)-1)/sqrt(1-(sqrt(2)-1)^2*(cot(x_for/180*pi/2))^2));
    ty = double((sqrt(2)-1)^2/sqrt(3-(cot(x_for/180*pi/2))^2));
    y4(idx) =2/15*((3*(sqrt(2)-1)+4/sqrt(3))*sin(x_for/180*pi)-6*(1-cos(x_for/180*pi)))...
        -(8/5/pi)*sin(x_for/180*pi)*(2*(sqrt(2)-1)*acos(tx*cot(x_for/180*pi/2))+1/sqrt(3)*acos(ty*cot(x_for/180*pi/2)))...
        +(8/5/pi)*(1-cos(x_for/180*pi))*(2*acos((sqrt(2)+1)*tx/sqrt(2))+acos((sqrt(2)+1)*ty/sqrt(2)));
end


x = [x1 x2 x3 x4];
y = [y1 y2 y3 real(y4)];
plot(x,y,varargin{:})

% y_cum = cumsum(y)*step_size;
% plot(x,y_cum)

end