function gRadii = sp8_plotGrainTrajSel(fullGTs,Vox,Gs,varargin)
%sp8_plotGrainTrajSel Plot 'selected' grain trajectories
%   
%   [h, rMean] = sp8_plotGrainTraj(fullGTs,Vox,Gs) plots grain trajectories
%   for grains (Gs) supplied by user. The voxel size (or voxel side length)
%   is given by the input variable vox. The function returns the grain
%   radii for the given grains.
%   
%   Options
%   ----------
%   'MeanR' - (def 'off') to show the mean grain radius on the plot turn
%             this option 'on'
%   'Color' - plot/patch line colors (def [0 0 0])
%   'Alpha' - alpha value (def 1)
%   
%   
%   Jules Dake
%   Uni Ulm, 02 May 2016
%   


%% Parse input variables
p = inputParser;

addRequired(p,'fullGTs',@isstruct);
addRequired(p,'Vox',@isnumeric);
addRequired(p,'Gs',@isnumeric);

defaultMeanR = true;
addParameter(p,'MeanR',defaultMeanR,@islogical);
defaultColor = [0 0 0];
addParameter(p,'Color',defaultColor,@isnumeric);
defaultAlpha = 1;
addParameter(p,'Alpha',defaultAlpha,@isnumeric);

parse(p,fullGTs,Vox,Gs,varargin{:});

meanR = p.Results.MeanR;
myColor = p.Results.Color;
myAlpha = p.Results.Alpha;


%% Set some more variables
def_lineWidth = 1;
numGs = length(Gs);
% If color is on uint8 scale, rescale
if max(myColor(:)) > 1
    myColor = double(uint8(myColor))/255;
end

gRadii = horzcat(fullGTs.gradius);
% calculate mean grain radius with 'bad' grains excluded
rMean = nanmean(gRadii)*Vox;
% get rid of extra grains
gRadii = gRadii( ismember( fullGTs(1).labels,Gs ),: );


%% Plot
t = horzcat(fullGTs.time);
t2 = repmat(t,numGs,1);
% Add NaN's to the end so that 'patch' draws a line and not a close polygon
gRadii(:,end+1) = NaN;
t2(:,end+1) = NaN;

% figure;
if myAlpha < 1
    p = patch(t2',Vox*gRadii',myColor,...
        'EdgeColor',myColor,...
        'LineWidth',def_lineWidth,...
        'EdgeAlpha',myAlpha);
    box on
else
    p = plot(t2',Vox*gRadii','LineWidth',def_lineWidth,'Color',myColor);
end

xlabel('annealing time (min)')
ylabel('$R$ ($\mu$m)', 'Interpreter', 'Latex')

end

