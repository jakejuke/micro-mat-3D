function [R2dR7dt, R7RMean, dR7dt] = sp8_r2drdt(radmat,t,vs,varargin)
%SP8_R2DRDT Calculate normalized growth rates (R*R*dR/dt)
%   This function takes grain size information to calculate the growth
%   rates of individual grains. For the first timestep the forward
%   difference is used, for the final the reverse difference, and for all
%   intermediate timesteps the central difference.
%   Also generates a plot.
%   
%   Inputs:
%       radmat - 2D matrix with grain size (rows) for each timestep
%                (columns)
%            t - annealing times, e.g. [0 30 60 90]/60 % in hours
%           vs - voxel size (if already in radmat, set to one)
%   
%   Outputs:
%       RdR7dt - normalized growth rate R*dR/dt
%      R/RMean - normalized grain size R/<R>
%
%   Examples:
%       [RdR7dt, R7RMean] = sp8_rdrdt(radmat,t,vs);
%       [RdR7dt, R7RMean] = sp8_rdrdt(R,t,vs,'RMean',Rm,'P2P','central');
%       
%   
% Jules Dake, Uni Ulm, Aug. 2014
% 

% This function is kind of like: dR = gradient(R,t)


%% Parse input variables

p = inputParser;

% required parameters
addRequired(p,'radmat',@isnumeric);
addRequired(p,'t',@isnumeric);
addRequired(p,'vs',@isnumeric);
% optional parameters
defaultRMean = 0;
defaultDeference = 'all';
defaultColor = 'b';

addParameter(p,'RMean',defaultRMean,@isnumeric);
addParameter(p,'Difference',defaultDeference,@ischar);
    errorStr = '''Color'' must be a string or 1x3 matrix';
    validationFcn = @(x) assert(ischar(x) || isnumeric(x),errorStr);
addParameter(p,'Color',defaultColor,validationFcn);

parse(p,radmat,t,vs,varargin{:});

RMean = p.Results.RMean;
method = p.Results.Difference;
plotColor = p.Results.Color;

% marker size for scatter plot
mSize = 2;


%% Set grain size and mean grain size mats

R = radmat*vs;
R2dR7dt = nan(size(R));
dR7dt = nan(size(R));
% set NaN's in R to zero
% Could be a problem, if all the grains are not tracked!
R(isnan(R)) = 0;

if RMean == 0
    % Could be a problem, if all the grains are not tracked!
    % Don't use R to calc. RMean; NaN's set to zero!
    RMean = nanmean(radmat*vs);
    display('Calculating mean grain radii from grain radius matrix:')
    display(num2str(RMean))
elseif length(RMean) == length(R(1,:))
    display('Using mean grain radii from user:')
    display(num2str(RMean))
else
    error('dimension mismatch: R-RMean')
end


%% Calculate growth rates

switch lower(method)
    case 'forward'
        disp('Method is forward')
        
    case 'central'
        disp('Method is central')
    case {'reverse','backward'}
        disp('Method is reverse')
        for I = 1:size(R,1)
            for J = 2:length(R(I,:))
                % reverse difference
                R2dR7dt(I,J) = (R(I,J)-R(I,J-1))/(t(J)-t(J-1))*R(I,J)*R(I,J);
            end
        end
    case 'all'
        disp('Method is all')
        for I = 1:size(R,1)
            % forward difference for the first point
            R2dR7dt(I,1) = (R(I,2)-R(I,1))/(t(2)-t(1))*R(I,1)*R(I,1);
            % centeral difference for the middle points
            for J = 2:length(R(I,:))-1
                R2dR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1))*R(I,J)*R(I,J);
                dR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1));
            end
            % reverse difference for the final point
            R2dR7dt(I,end) = (R(I,end)-R(I,end-1))/(t(end)-t(end-1))*R(I,end)*R(I,end);
        end
end



% Normalize radii
R7RMean = nan(size(R));
for I = 1:length(RMean)
    R7RMean(:,I) = R(:,I)/RMean(I);
end


%% Plot
if strcmpi('central',method) && length(R(1,:)) > 2
    display('Plotting only points from central difference')
    R7RMean = R7RMean(:,2:end-1);
    R2dR7dt = R2dR7dt(:,2:end-1);
    dR7dt = dR7dt(:,2:end-1);
elseif strcmpi('central',method)
    display('Cannot use the central difference; two or less timesteps!')
elseif ~strcmpi('all',method)
    display('Options for P2P are: ''all'' and ''central''')
    display('Plotting all')
end

% figure; 
% scatter(R7RMean(:),R2dR7dt(:),mSize,plotColor,'filled'); hold on;
scatter(R7RMean(:),R2dR7dt(:),mSize,plotColor,'filled');
hold on
xticks = get(gca,'XTick'); yticks = get(gca,'YTick');
line([xticks(1),xticks(end)],[0,0],'Color','k')
line([1,1],[yticks(1),yticks(end)],'Color','k')
xlabel('{\itR}/\langle{\itR}\rangle')
ylabel('{\itR}^2\Delta{\itR}/\Delta{\itt}  (\mum^3/min)')
hold off

end

