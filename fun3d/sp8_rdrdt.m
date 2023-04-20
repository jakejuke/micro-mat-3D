function [RdR7dt, R7RMean, MGamma, fitresult, gof] = sp8_rdrdt( fullGTs, varargin )
%SP8_RDRDT Calculates normalized growth rates (R*dR/dt)
%   This function calculates growth rates of individual grains. For the
%   first timestep the forward difference is used, for the final the
%   reverse difference, and for all intermediate timesteps the central
%   difference. Also generates a plot and fit of Hillert's predicted growth
%   rates.
%   
%   Inputs:
%      fullGTs - grain tables containing grain radius, and annealing times
%
%   Optional Inputs:
%    'VoxSize' - voxel size (default value 1)
%      'RMean' - vector of mean sizes with length(fullGTs)
%        'P2P' - points to plot (default 'all'), 'central' or 'forward'
%      'Alpha' - plot semitransparent points (default is 1)
%      'Color' - RGB values for plot color
%       'Plot' - 'on' (def) or 'off'
%   'FitStart' - x-value from which to start fitting (def 0)
%      'Zeros' - true (def)/false, includes grains that shrink to zero
%   
%   Outputs:
%       RdR7dt - normalized growth rate R*dR/dt
%      R/RMean - normalized grain size R/<R>
%       MGamma - reduced mobility from Hillert fit
%    fitresult - result of Hillert fit
%          gof - goodness of Hillert fit
%
%   Examples:
%       [y, x] = sp8_rdrdt(fullGTs,'VoxSize',5,'P2P','central');
%       
%   
% Jules Dake
% Uni Ulm, Aug 2014
% Modified Apr 2016
% 

% This function is kind of like: dR = gradient(R,t)

%% Parse input variables
p = inputParser;

% required parameters
addRequired(p,'fullGTs',@isstruct);
% optional parameters
defRMean = 0;
defPoints2Plot = 'all';
defVoxSize = 1;
defAlpha = 1;
defaultColor = [0 0 1];
defaultPlot = 'on';
defaultFitStart = 0;
defaultZeros = true;
defaultScope = 'global';

addParameter(p,'RMean',defRMean,@isnumeric);
addParameter(p,'P2P',defPoints2Plot,@ischar);
addParameter(p,'VoxSize',defVoxSize,@isnumeric);
addParameter(p,'Alpha',defAlpha,@isnumeric);
addParameter(p,'Color',defaultColor,@isnumeric);
addParameter(p,'Plot',defaultPlot,@ischar);
addParameter(p,'FitStart',defaultFitStart,@isnumeric);
addParameter(p,'Zeros',defaultZeros,@islogical);
addParameter(p,'Scope',defaultScope,@ischar);

parse(p,fullGTs,varargin{:});
RMean = p.Results.RMean;
p2p = p.Results.P2P;
vs = p.Results.VoxSize;
myAlpha = p.Results.Alpha;
myColor = p.Results.Color;
plotStatus = p.Results.Plot;
fitStart = p.Results.FitStart;
plotZeros = p.Results.Zeros;
scope = p.Results.Scope;


%% Define some variables
t = horzcat(fullGTs.time); % *in minutes for black hole data
% If color is on uint8 scale, rescale
if max(myColor(:)) > 1
    myColor = double(uint8(myColor))/255;
end
R = horzcat(fullGTs.gradius)*vs;
RdR7dt = nan(size(R));
dR7dt = nan(size(R));

% Now set first NaN in each row of R to zero
%   *could be a problem, if all the grains are not tracked properly
if plotZeros
    Rtest = R;
    R(isnan(R)) = 0;
    for I = 2:length(fullGTs)
        cLeft = isnan( Rtest(:,I-1) );
        coi = isnan( Rtest(:,I) );
        ind = and(cLeft,coi);
        R(ind,I) = NaN;
    end
    % % Alternate method to set first occurance of NaN to zero
    % R(isnan(R)) = 0;
    % Rdiff = diff(R,1,2);
    % R2 = R(:,2:end);
    % R2(Rdiff==0) = NaN;
    % R(:,2:end) = R2;
    
    % Indices in R for the point at which a grain disappears
    Rzeros = R == 0;
end


%% Calculate growth rates
% Central difference for middle points, works with non-uniform spacing
if strcmpi('central',p2p)
    for I = 1:size(R,1)
        for J = 2:length(R(I,:))-1
            RdR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1))*R(I,J);
            dR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1));
        end
    end
    
elseif strcmpi('forward',p2p)
    RdR7dt(:,1:end-1) = R(:,1:end-1).*diff(R,1,2);
    
else % use all (mixed)
    for I = 1:size(R,1)
        % forward difference for the first point
        RdR7dt(I,1) = (R(I,2)-R(I,1))/(t(2)-t(1))*R(I,1);
        % centeral difference for the middle points
        for J = 2:length(R(I,:))-1
            RdR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1))*R(I,J);
            dR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1));
        end
        % reverse difference for the final point
        RdR7dt(I,end) = (R(I,end)-R(I,end-1))/(t(end)-t(end-1))*R(I,end);
    end
end

%% Remove 'bad' grains
if any(contains(fieldnames(fullGTs),'badGrain'))
    badGrains = any(horzcat(fullGTs.badGrain),2);
    R(badGrains,:) = NaN;
else
    warning('No bad grains detected, skipping bad grain removal')
end
% % Could also remove surface grains like this:
% surfGs = horzcat(fullGTs.surfGrain);
% R(surfGs) = NaN;
RdR7dt(isnan(R)) = NaN;
% Get rid of any grains with zero radius --> probably not a problem anymore
%   with new code
RdR7dt(R==0) = NaN;
R(R==0) = NaN;


%% Normalize grain radii
% Find RMean
if strcmpi(scope,'local')
    display('Normalizing with local grain radius')
    if RMean == 0
        % 'exclude' grain of interest when calculating RMeanLoc
        RMean = sp8_rMeanLoc( fullGTs, 'GOI', 'exclude', 'Weight', 'number' );
        RMean = RMean*vs;
    end
    % Normalization
    R7RMean = R./RMean;
else
    display('Normalizing with global grain radius')
    if RMean == 0
        RMean = nanmean(R);
        display('Calculating mean grain radii from grain radius matrix:')
        display(num2str(RMean))
    elseif length(RMean) == length(R(1,:))
        display('Using mean grain radii from user:')
        display(num2str(RMean))
    else
        error('dimension mismatch: R-RMean')
    end
    % Normalization
    R7RMean = nan(size(R));
    for I = 1:length(RMean)
        R7RMean(:,I) = R(:,I)/RMean(I);
    end
end


%% Check more options
if strcmpi('central',p2p) && length(R(1,:)) > 2
    display('Using central difference')
    % R7RMean = R7RMean(:,2:end-1);
    % RdR7dt = RdR7dt(:,2:end-1);
    % dR7dt = dR7dt(:,2:end-1);
    RdR7dt(:,[1,end]) = NaN;
elseif strcmpi('central',p2p)
    display('Cannot use the central difference; two or less timesteps!')
elseif strcmpi('forward',p2p)
    display('Using forward difference')
    for I = 1:length(t)-1
        dt = t(I+1) - t(I);
        RdR7dt(:,I) = RdR7dt(:,I)/dt;
    end
end

if plotZeros
    % I'm interested in the last measurement of R, thus shift columns left
    Rzeros = circshift(Rzeros,-1,2);
    xZeros = R7RMean( Rzeros );
    yZeros = RdR7dt( Rzeros );
    xFinite = R7RMean( ~Rzeros );
    yFinite = RdR7dt( ~Rzeros );
end

x = R7RMean(:);
y = RdR7dt(:);
% Could just fit select growth rates
% y(or(x<0.5, x>2.5)) = 0;
% x(or(x<0.5, x>2.5)) = 0;

% % Get rid of 0,0 values, these mess up the fit!!
% y = y(x>0);
% x = x(x>0);

% Check for grains with zero radius
if any( x <= 0)
    warning('There are grains with radius zero!')
end

% Remove NaNs; they don't work during fitting. There may be more NaNs in y
% because if a grain disappears in the next time step, the difference could
% be NaN (depends 'Zeros' option)
x = x(isfinite(y));
y = y(isfinite(y));

% Remove NaNs again; they don't work during fitting. There may be more NaNs
% in x if RMeanLoc is used and a grain has no neighbors. This case does
% exist for BH near the very bottom of the sample.
y = y(isfinite(x));
x = x(isfinite(x));

%% Hillert's fit
% R*dR/dt = (8/9)*alpha*M*gamma*(R/Rmean - 9/8)
% for the 3D case, alpha is equal to unity
% ---
% Set fit options
ft = fittype( '8/9*a*(x-9/8)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 1;
% Fit data and plot line
xFit = x( x >= fitStart );
yFit = y( x >= fitStart );
[fitresult, gof] = fit( xFit, yFit, ft, opts );
MGamma = fitresult.a;


if strcmpi(plotStatus,'on')
    % h = figure;
    if myAlpha < 1
        if plotZeros
            scatter(xFinite(:), yFinite(:), 6, myColor, 'filled');
            hold on
            scatter(xZeros(:), yZeros(:), 6, [.25 .25 .25], 'filled');
        else
            scatter(x(:), y(:), 6, myColor, 'filled');
            hold on
        end
        alpha(myAlpha)
    else
        if plotZeros
            plot(xFinite,yFinite,'.','MarkerSize',4,'Color',myColor);
            hold on
            plot(xZeros,yZeros,'.','MarkerSize',4,'Color',[.5 .5 .5]);
        else
            plot(x,y,'.','MarkerSize',4,'Color',myColor);
            hold on
        end
    end
    
    box on
    % line([1,1],[yticks(1),yticks(end)],'Color','k')
    xlabel('$R/\langle R \rangle$','Interpreter','Latex')
    ylabel('$R\Delta R/\Delta t$','Interpreter','Latex')
    
    % Draw some lines
    xlims = xlim; ylims = ylim;
    line([xlims(1),xlims(2)+1],[0,0],'Color','k')
    % Draw vertical line at R_cr
    line([9/8, 9/8], [ylims(1), ylims(2)], 'Color', 'k', 'LineStyle', '-')
    % % line([9/8, 9/8], [-400, 600], 'Color', 'k', 'LineStyle', '-')
    % % line([9/8, 9/8], [-150, 250], 'Color', 'k', 'LineStyle', '-')
    % % line([9/8, 9/8], [-1.5, 2.5], 'Color', 'k', 'LineStyle', '-')
    
    % Plot Hillert's fit
    xx = linspace(fitStart,xlims(2));
    yy = 8/9 * MGamma * (xx - 9/8);
    plot( xx, yy, 'r');
    
    % Turn on data cursor
    h = gcf;
    dcm = datacursormode(h);
    datacursormode on
    set(dcm,'updatefcn',@myfunction)
end


%%% Tip subfunction %%%
function output_txt = myfunction(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');

[R,C] = find(RdR7dt==pos(2));
gLab = fullGTs(1).labels(R(1));

if length(R) > 1
    warning('Multiple grains with same rotation rate!')
    warning('Only showing the first')
end

output_txt = {['X: ', num2str(pos(1),4)],...
              ['Y: ', num2str(pos(2),4)],...
              ['Grain: ', num2str(gLab)]};
end

end


