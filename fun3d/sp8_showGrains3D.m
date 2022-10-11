function [pos,va,target] = sp8_showGrains3D(g,full3Ds,fullGTs,varargin)
%SP8_SHOWGRAINPAIR Save images of grains in 3D across multiple timesteps
%   
%   sp8_showGrains3D(g,full3Ds,fullGTs) plots isosurfaces of grains defined
%   by vector of integers g. full3Ds and fullGTs are the 3D labelled
%   matrices and grain tables, respectively, the dimensions of which
%   correspond to the number of timesteps.
%   
%   
%   
%   
%   Jules Dake
%   Uni Ulm, 31.10.2014
%   
%   Update lines 142 and 224 today with a smooth3 command. Makes a huge
%   difference in the result.
%   7 Aug 2019


%% Set some "user" variables
baseAxisLength = 20;


%% Parse input variables
p = inputParser;

addRequired(p,'g',@isnumeric);
addRequired(p,'full3Ds',@iscell);
addRequired(p,'fullGTs',@isstruct);

defaultGOI = g(1);
addParameter(p,'goi',defaultGOI,@isnumeric);

defaultMinMaxR = (sqrt(2)-1);
addParameter(p,'minmaxR',defaultMinMaxR,@isnumeric);

defaultPath = '~/Desktop/';
addParameter(p,'path',defaultPath,@ischar);

defaultSuffix = '_3D';
addParameter(p,'suffix',defaultSuffix,@ischar);

defaultRotation = 'off';
errorStr = 'Value must be the index of a given timestep or a string';
validationFcn = @(x) assert(ischar(x) || isnumeric(x),errorStr);
addParameter(p,'rotation',defaultRotation,validationFcn);

defaultAxis = 'off';
addParameter(p,'axis',defaultAxis,@ischar);

defaultView = [37.5, 30]; % view(37.5,30);
addParameter(p,'view',defaultView,@isnumeric);

defaultMoreViewOps = struct([]); % view(37.5,30);
addParameter(p,'MoreViewOptions',defaultMoreViewOps,@isstruct);

defaultPrint = 'on';
addParameter(p,'Print',defaultPrint,@ischar);

parse(p,g,full3Ds,fullGTs,varargin{:});

goi = p.Results.goi;
minmaxR = p.Results.minmaxR;
printPath = p.Results.path;
fnamesuf = p.Results.suffix;
rotOp = p.Results.rotation;
axisOp = p.Results.axis;
viewOp = p.Results.view;
mViewOps = p.Results.MoreViewOptions;
printOp = p.Results.Print;


%% Set BoundingBox
% getBoundingBox returns the 'BoundingBox' as:
%   BB = [xMin, yMin, zMin, xMax, yMax zMax]
%   *This is different than the 'BoundingBox' returned by regionprops!

for I=1:length(full3Ds)
    tempBB{I} = getBoundingBox(g(ismember(g,full3Ds{I})),full3Ds{I});
end

BB = vertcat(tempBB{:});
BB(BB<1) = 1; % Fix 7 Aug 2019
xMin = min(BB(:,1)); yMin = min(BB(:,2)); zMin = min(BB(:,3));
xMax = max(BB(:,4)); yMax = max(BB(:,5)); zMax = max(BB(:,6));

% TEMP fix 8 May 2016 %
[yS, xS, zS] = size(full3Ds{1});
if xMax > xS
    xMax = xS;
end
if yMax > yS
    yMax = yS;
end
if zMax > zS
    zMax = zS;
end
% END temp fix %


%% Apply BoundingBox to all timesteps and set other grains to zero

% Change this block of code. Call new 3D cell array crop3Ds and if there
% are no grains for a given timestep, remove it! This should solve problems

for I=1:length(full3Ds)
    A = full3Ds{I}(yMin:yMax,xMin:xMax,zMin:zMax);
    B = ismember(A,g);
    A(~B) = 0;
    full3Ds{I} = A;
end
clear A B


%% Find max rotation

% use miniGTs to speed things up
miniGTs = makeMiniGT(fullGTs,goi);
misor = sp8_makeMisor(miniGTs,'method','relative');

if strcmpi(rotOp,'max')
    [~,maxRotI] = nanmax(misor);
elseif isnumeric(rotOp)
    maxRotI = rotOp;
else
    maxRotI = 1;
end


%% Set view

% %Position figure in the right upper corner
% scrsz = get(0,'ScreenSize');
% figure('Position',[scrsz(3) scrsz(4) scrsz(3)/4 scrsz(4)/3]);

if strcmpi(rotOp,'max')
    I = maxRotI - 1;
    display('Setting view at one timestep before maximum rotation')
else
    I = maxRotI;
end

p = zeros(length(g),1);
f = figure;



for J=1:length(g)
    p(J) = patch(isosurface(smooth3(full3Ds{I}==g(J))));
    gColor = fullGTs(I).orient(g(J),:)*.5/minmaxR + 0.5;
    set(p(J),'FaceColor',gColor,'EdgeColor','none','AmbientStrength',0.2)
end
% View settings
[y, x, z] = size(full3Ds{I});
xlim([0 x]); ylim([0 y]); zlim([0 z]);
axis off; axis equal; % axis tight;
view(viewOp(1),viewOp(2));
camlight; lighting gouraud

% plot x,y,z axes at origin
mArrowAxes = plotAxes3D(baseAxisLength);

if strcmpi(rotOp,'max')
    % USE: mymisorientation(r(I),r(I-1))
    % This gives rotation to go from the current timestep to the next!!!
    [~,rotA] = mymisorientation(fullGTs(I+1).orient(goi,:),...
        fullGTs(I).orient(goi,:));
    mRotAxis = sp8_showRotAxis(goi,full3Ds{I},rotA);
end

if isempty(mViewOps)
    display('Set view options and press enter when done')
    pause
end

% delete axes
if strcmpi(rotOp,'max')
    delete(mRotAxis)
end
delete(mArrowAxes)

% set light for new position
delete(findall(gcf,'Type','light'))
camlight('headlight', 'infinite'); lighting gouraud

if isempty(mViewOps)
    % Save settings
    pos = campos;
    va = camva;
    target = camtarget;
    
else
    % Import settings
    pos = mViewOps.campos;
    va = mViewOps.camva;
    target = mViewOps.camtarget;
end


%% Save images

for I=1:length(full3Ds)
    
    % set file name
    if strcmpi(axisOp,'on')
        % fname = [printPath fullGTs(I).timestep '_3D_g' num2str(goi) '_wa'];
        fname = [printPath 'g' num2str(goi) 'wa_' num2str(fullGTs(I).time) fnamesuf];
    else
        % fname = [printPath fullGTs(I).timestep '_3D_g' num2str(goi)];
        fname = [printPath 'g' num2str(goi) '_' num2str(fullGTs(I).time) fnamesuf];
    end
    
    % delete patches from previous image if any
    if any(p)
        try
            delete(p)
        catch ME % if a grain has disappeared then run this
            display(ME.identifier)
            display(ME.message)
            delete(p(ismember(g,fullGTs(I-1).labels)))
        end
    end
    % delete rotation axis from previous image
    if strcmpi(axisOp,'on') && I > 1
        delete(mRotAxis)
        delete(h_text)
    end

    for J=1:length(g)
        if isfinite(fullGTs(I).labels(g(J)))
            p(J) = patch(isosurface(smooth3(full3Ds{I}==g(J))));
            gColor = fullGTs(I).orient(g(J),:)*.5/minmaxR + 0.5;
            set(p(J),'FaceColor',gColor,'EdgeColor','none','AmbientStrength',0.2)
        end
    end
    
    if strcmpi(axisOp,'on') && I < length(full3Ds)
        % USE: mymisorientation(r(I),r(I-1))
        % This gives rotation to go from the current timestep to the next!!
        [~,rotA] = mymisorientation(fullGTs(I+1).orient(goi,:),...
            fullGTs(I).orient(goi,:));
        mRotAxis = sp8_showRotAxis(goi,full3Ds{I},rotA);
        h_text = text(.9,.9,['rotation: ' num2str(misor(I+1))],...
            'Units','normalized','Color',[0 0 1]);
    end
    
    % restore view settings from first image
    setCamSettings(pos,va,target)
    
    if printOp
        print('-dpng','-r300',fname)
    end
end

display(num2str(misor))

if ~strcmpi(printOp,'on')
    display('Did not save images')
    display('Turn ''Print'' option ''on'' to save')
end

end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%

% get label and orientation for GOI and make a mini Grain Table
function miniGT = makeMiniGT(fullGTs,goi);

miniGT = struct('labels',[],'orient',[],'time',[]);

for I=1:length(fullGTs)
    miniGT(I,1).labels = fullGTs(I).labels(goi);
    miniGT(I,1).orient = fullGTs(I).orient(goi,:);
    miniGT(I,1).time = fullGTs(I).time;
end

end


% get bounding box
function BB = getBoundingBox(g,A)

if isempty(g)
    BB = nan(1,6);
    return
end

B = A == g(1);
for I=2:length(g)
    B = or(B, A == g(I));
end

A(~B) = 0;

STATS = regionprops(A,'BoundingBox');
tempBB = STATS(g(1)).BoundingBox;
for I=2:length(g)
    tempBB = [tempBB; STATS(g(I)).BoundingBox];
end

xMin = floor(min(tempBB(:,1)));
yMin = floor(min(tempBB(:,2)));
zMin = floor(min(tempBB(:,3)));
xMax = ceil(max(tempBB(:,1) + tempBB(:,4)));
yMax = ceil(max(tempBB(:,2) + tempBB(:,5)));
zMax = ceil(max(tempBB(:,3) + tempBB(:,6)));

BB = [xMin, yMin, zMin, xMax, yMax zMax];

end


function setCamSettings(pos,va,target)

% restore view settings from first image
campos(pos); camva(va); camtarget(target)
delete(findall(gcf,'Type','light'))
camlight('headlight', 'infinite'); lighting gouraud

end

