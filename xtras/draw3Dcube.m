function [h, v2] = draw3Dcube(U1,v1)
%plot3Dcube Plot a cube in 3D
%   
%   
%   Jules Dake
%   26 Sep 2016
%   

a = 0.85;
org = [0 0 0];
limValue = sqrt(3);
colors = [ 0.0  0.5  0.0;
           1.0  0.0  0.0;
           0.0  0.0  1.0;
           1.0  0.35 0.0;
           0.65 0.65 0.65;
           1.0  1.0  0.0 ];

if nargin == 1
    v1(1,:) = [-1, -1,  1,  1, -1, -1,  1,  1];
    v1(2,:) = [-1,  1,  1, -1, -1,  1,  1, -1];
    v1(3,:) = [-1, -1, -1, -1,  1,  1,  1,  1];
end

% h = figure;
axis equal
xlim([-limValue limValue]); ylim([-limValue limValue]); zlim([-limValue limValue])
view(120,20)

% Apply transformation (left-handed matrix multiplication, right-hand-rule
% for positive rotation)
v2 = U1*v1;


% Draw cube faces
patch('Faces', [4 8 7 3 4], 'Vertices', v2', 'FaceColor', colors(1,:), 'FaceAlpha', a)
patch('Faces', [3 7 6 2 3], 'Vertices', v2', 'FaceColor', colors(2,:), 'FaceAlpha', a)
patch('Faces', [2 6 5 1 2], 'Vertices', v2', 'FaceColor', colors(3,:), 'FaceAlpha', a)
patch('Faces', [1 5 8 4 1], 'Vertices', v2', 'FaceColor', colors(4,:), 'FaceAlpha', a)
patch('Faces', [1 4 3 2 1], 'Vertices', v2', 'FaceColor', colors(5,:), 'FaceAlpha', a+.1)
patch('Faces', [5 8 7 6 5], 'Vertices', v2', 'FaceColor', colors(6,:), 'FaceAlpha', a)


% % Draw lower square
% x = [v2(1,1:4), v2(1,1)];
% y = [v2(2,1:4), v2(2,1)];
% z = [v2(3,1:4), v2(3,1)];
% l_handle=line(x,y,z);
% set(l_handle,'color',defColor)
% 
% % Draw upper square
% x = [v2(1,5:8), v2(1,5)];
% y = [v2(2,5:8), v2(2,5)];
% z = [v2(3,5:8), v2(3,5)];
% l_handle=line(x,y,z);
% set(l_handle,'color',defColor)
% 
% % Draw vertical lines connecting squares
% for I=1:4
%     x = [v2(1,I), v2(1,I+4)];
%     y = [v2(2,I), v2(2,I+4)];
%     z = [v2(3,I), v2(3,I+4)];
%     l_handle = line(x,y,z);
%     set(l_handle,'color',defColor)
% end

% % add some color to corresponding x,y,z axes of unit cell
% a = [v2(:,1), v2(:,4)]; % line from origin to [1 0 0], x-axis
% l_handle = line(a(1,:),a(2,:),a(3,:));
% set(l_handle,'color',[1 .2 .2])
% b = [v2(:,1), v2(:,2)]; % line from origin to [1 0 0], x-axis
% l_handle = line(b(1,:),b(2,:),b(3,:));
% set(l_handle,'color',[.2 1 .2])
% c = [v2(:,1), v2(:,5)]; % line from origin to [1 0 0], x-axis
% l_handle = line(c(1,:),c(2,:),c(3,:));
% set(l_handle,'color',[.2 .2 1])

% set view and mark origin with blue sphere
hold on
% scatter3([v1(1,1) v2(1,1)],[v1(2,1) v2(2,1)],[v1(3,1) v2(3,1)],'filled')
% xlabel('x'); ylabel('y'); zlabel('z');

% % plot rotation axis
% r = U2r(U1); % ----> check this function for correctness!
% % % old way of normalizing r
% % [~,n] = mymisorientation([0 0 0],r);
% n = r/norm(r);
% % double length of unit vector n (so it will be as long as other vectors)
% n2 = n*2 + org;
% % mArrow3(org,n2,'color','k');
% mArrow3([0 0 0],-n2,'color','k');

% plotAxes3D(2,'origin',org);

end

