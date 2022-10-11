function sp8_misor_v_sampleR(fullGT)
%sp8_misor_v_sampleR generates a scatter plot of a grains misorientation
%(from the Cube texture) vs the distance from its center of mass to the
%specimen's center of rotation. In the case of the Black Hole the rotation
%axis is the z or longitutal axis of the cylindrical specimen.
%
%   sp8_misor_v_sampleR(fullGT)
%   The structure fullGT must already have the fields 'corrOrient' and
%   'phase'. Generates the plots described above.
%
%   
%   Jules Dake
%   22 Jul 2017
%   

if ~isfield(fullGT,'corrOrient')
    error('Field ''corrOrient'' required. Run texComp_orient3.m first.')
end
if ~isfield(fullGT,'phase')
    error('Field ''phase'' required. Run texComp_orient3.m first.')
end

%% Add field misorCube to fullGTs if not already present
% Calculate misorientation angle wrt Cube texture (it is in this case (with
% corrOrient) actually just the orientation angle)
if ~isfield(fullGT,'misorCube')
        m = nan(length(fullGT.labels), 1);
        for G=1:length(fullGT.labels)
            if isfinite(fullGT.corrOrient(G,1))
                m(G) = calcmisor(eye(3),r2U(fullGT.corrOrient(G,:)));
            end
        end
        fullGT.misorCube = m;
end


%% Save colors for each grain
% Calculate the distance of each grain's center of mass to the samples
% z-axis, i.e. the rotation axis
    r = nan(length(fullGT.labels), 1);
    for G=1:length(fullGT.labels)
        if isfinite(fullGT.corrOrient(G,1))
            r(G) = sqrt((fullGT.centroid(G,1) - 321/2)^2 + ...
                (fullGT.centroid(G,2) - 321/2)^2);
        end
    end
    fullGT.centroidR = r;

clear TS m r


%% Scatter plot
c = getcolors(fullGT);
figure
scatter((fullGT.centroidR*5).^2,fullGT.misorCube,6,c,'filled')
box on
hold on
alpha(0.65)
% 
a = gca;
maxTick = max(a.XTick);
[ M, MX ] = binXYdata( (fullGT.centroidR*5).^2, fullGT.misorCube, ...
    0:maxTick/14:maxTick );
plot(MX,M,'-rx','LineWidth',.9,'MarkerSize',4)
% rescale x-axis from r^2 to r
a = gca;
tempTicks = a.XTick;
tempTicks(2:2:end) = [];
a.XTick = tempTicks;
a.XTickLabel = round(sqrt(a.XTick));
% axis lables
xlabel('specimen radius (\mum)')
ylabel('rotation angle (deg)')


%% Contour plot
x = [(fullGT.centroidR*5).^2, fullGT.misorCube];
gridx1 = 0:5e5/30:5e5;
gridx2 = 0:60/30:60;
[x1,x2] = meshgrid(gridx1, gridx2);
x1 = x1(:);
x2 = x2(:);
xi = [x1 x2];
figure
ksdensity(x,xi)
% top view, no edge lines and smooth
view(0,90)
s = findobj(gcf, 'type', 'surface');
s.EdgeColor = 'none';
shading(gca,'interp')
% rescale x-axis from r^2 to r
a = gca;
tempTicks = a.XTick;
tempTicks(2:2:end) = [];
a.XTick = tempTicks;
a.XTickLabel = round(sqrt(a.XTick));
% axis lables
xlabel('specimen radius (\mum)')
ylabel('rotation angle (deg)')


end


%-- Subfuctions --%
function c = getcolors(fullGT)
% texture component colors
colorsTex = {[0.1 0.3 0.85];     % Cube Up
             [0.3 0.1 0.85];     % Cube Low
             [0.35 0.7 1.0];     % Upper Cube tail - light blue
             [0.7 0.35 1.0];     % Lower Cube tail - light pink
             [1.0 0.0 0.8];      % myZ - magenta
             [0.0 0.8 0.2];      % GM - green
             [0.5 0.5 0.5]};     % Rest - gray
% set colormap matrix
c = nan(length(fullGT.labels),3);
c(fullGT.phase == 1,:) = repmat(colorsTex{1},nnz(fullGT.phase == 1),1);
c(fullGT.phase == 2,:) = repmat(colorsTex{2},nnz(fullGT.phase == 2),1);
c(fullGT.phase == 3,:) = repmat(colorsTex{3},nnz(fullGT.phase == 3),1);
c(fullGT.phase == 4,:) = repmat(colorsTex{4},nnz(fullGT.phase == 4),1);
c(fullGT.phase == 5,:) = repmat(colorsTex{5},nnz(fullGT.phase == 5),1);
c(fullGT.phase == 6,:) = repmat(colorsTex{6},nnz(fullGT.phase == 6),1);
c(fullGT.phase == 7,:) = repmat(colorsTex{7},nnz(fullGT.phase == 7),1);
end