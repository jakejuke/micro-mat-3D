function [h, rMean, gRadii] = sp8_plotGrainTraj(fullGTs,vox,varargin)
%sp8_plotGrainTraj Plot grain trajectories
%   
%   [h, rMean] = sp8_plotGrainTraj(fullGTs,vox) plots grain trajectories
%   for 10% of the grains in fullGTs. The voxel size (or voxel side length)
%   is given by the input variable vox. The function returns the figure
%   handle h and the mean grain radius (for ALL grains!).
%   
%   Options
%   ----------
%   'fraction' - (def 0.1) the fraction of grain trajectories to plot
%   'seed' - (def NaN) the seed for picking the fraction of grains to plot
%            at random
%   'MeanR' - (def 'off') to show the mean grain radius on the plot turn
%             this option 'on'
%   'Color' - plot/patch line colors (def [0 0 0])
%   'Alpha' - alpha value (def 1)
%   
%   
%   Jules Dake
%   Uni Ulm, 21 Nov 2014
%   *Updated 22 Apr 2016
%   


%% Parse input variables
p = inputParser;

addRequired(p,'fullGTs',@isstruct);
addRequired(p,'vox',@isnumeric);

defaultGrainFraction = .5;
addParameter(p,'Fraction',defaultGrainFraction,@isnumeric);
defaultSeed = NaN;
addParameter(p,'Seed',defaultSeed,@isnumeric);
defaultMeanR = false;
addParameter(p,'MeanR',defaultMeanR,@islogical);
defaultColor = [0 0 0];
addParameter(p,'Color',defaultColor,@isnumeric);
defaultAlpha = 1;
addParameter(p,'Alpha',defaultAlpha,@isnumeric);

parse(p,fullGTs,vox,varargin{:});

gFrac = p.Results.Fraction;
randSeed = p.Results.Seed;
meanR = p.Results.MeanR;
myColor = p.Results.Color;
myAlpha = p.Results.Alpha;


%% Set some more variables
def_lineWidth = 0.5;
numGs = length(fullGTs(1).labels);
% If color is on uint8 scale, rescale
if max(myColor(:)) > 1
    myColor = double(uint8(myColor))/255;
end


%% Make random permutation of grains to plot
if (gFrac < 1) && isnan(randSeed)
    randListOfGrains = randperm(numGs);
elseif gFrac < 1
    s = RandStream('mt19937ar','Seed',randSeed);
    randListOfGrains = randperm(s,numGs);
else
    randListOfGrains = 'all';
end

% check if there are 'bad grains' that should be excluded
if isfield(fullGTs,'badGrain')
    badGrainIndex = sp8_excludeBadGrains(fullGTs);
    gRadii = horzcat(fullGTs.gradius);
    gRadii(badGrainIndex,:) = NaN;
    numGoodGrains = numGs - nnz(badGrainIndex);
else
    warning('No field ''badGrains''')
    gRadii = horzcat(fullGTs.gradius);
    numGoodGrains = numGs;
    badGrainIndex = zeros(length(randListOfGrains),1);
end

% calculate mean grain radius with 'bad' grains excluded
rMean = nanmean(gRadii)*vox;

% select first N grains from permutation
numGrains2plot = gFrac*numGoodGrains;
if isnumeric(randListOfGrains)
    J = 0;
    grains2plot = zeros(round(numGrains2plot),1);
    for I=1:numGs
        if ~badGrainIndex(randListOfGrains(I))
            J = J + 1;
            grains2plot(J) = randListOfGrains(I);
            if J >= round(numGrains2plot)
                display(['Plotting ' num2str(round(numGrains2plot)) ...
                ' ''good'' grains'])
                break
            end
        end
        if I == numGs
            display(['Could not find ' num2str(round(numGrains2plot)) ...
                ' ''good'' grains to plot'])
            display(['Plotting ' num2str(J) ' grain trajectories'])
        end
    end
    % set all grains in matrix gRadii to NaN's that are not in grains2plot
    gRadii(~ismember(fullGTs(1).labels,grains2plot),:) = NaN;
end


%% Plot
t = horzcat(fullGTs.time);
t2 = repmat(t,numGs,1);
% Add NaN's to the end so that 'patch' draws a line and not a close polygon
gRadii(:,end+1) = NaN;
t2(:,end+1) = NaN;

figure;
if myAlpha < 1
    h = patch(t2',vox*gRadii',myColor,...
        'EdgeColor',myColor,...
        'LineWidth',def_lineWidth,...
        'EdgeAlpha',myAlpha);
    box on
else
    h = plot(t2',vox*gRadii','LineWidth',def_lineWidth,'Color',myColor);
end

xlabel('annealing time (min)')
ylabel('$R$ ($\mu$m)', 'Interpreter', 'Latex')

% plot mean grain radius
if meanR
    hold on
    plot(t,rMean,'-dk','LineWidth',1,'MarkerSize',3,'MarkerFaceColor','k')
    % plot(t,rMean,'-k','LineWidth',1)
end

end

