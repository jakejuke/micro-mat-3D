function [dV7dt, R7RMean] = sp8_dvdt(volmat,t,vs,varargin)
%SP8_RDRDT Calculates normalized growth rates (R*dR/dt)
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

defaultRMean = 0;
defaultPoints2Plot = 'all';
defaultTEMP = 0;

% required parameters
addRequired(p,'radmat',@isnumeric);
addRequired(p,'t',@isnumeric);
addRequired(p,'vs',@isnumeric);
% optional parameters
addParameter(p,'RMean',defaultRMean,@isnumeric);
addParameter(p,'P2P',defaultPoints2Plot,@ischar);
addParameter(p,'Temp',defaultTEMP,@isnumeric);

parse(p,volmat,t,vs,varargin{:});

RMean = p.Results.RMean;
p2p = p.Results.P2P;
temp1 = p.Results.Temp;


%% Set grain size and mean grain size mats

V = volmat*vs^3;
R = (3/(4*pi)*volmat).^(1/3)*vs;
dV7dt = nan(size(V));
% set NaN's in R to zero
% Could be a problem, if all the grains are not tracked!
V(isnan(V)) = 0;
R(isnan(V)) = 0;

if RMean == 0
    % Could be a problem, if all the grains are not tracked!
    % Don't use R to calc. RMean; NaN's set to zero!
    RMean = nanmean(volmat*vs);
    display('Calculating mean grain radii from grain radius matrix:')
    display(num2str(RMean))
elseif length(RMean) == length(V(1,:))
    display('Using mean grain radii from user:')
    display(num2str(RMean))
else
    error('dimension mismatch: R-RMean')
end


%% Calculate growth rates
% Central difference for middle points, works with non-uniform spacing
for I = 1:size(V,1)
    % forward difference for the first point
    % RdR7dt(I,1) = (R(I,2)-R(I,1))/(t(2)-t(1))*R(I,1);
    dV7dt(I,1) = (V(I,2)-V(I,1))/(t(2)-t(1));
    % centeral difference for the middle points
    for J = 2:length(V(I,:))-1
        % RdR7dt(I,J) = (R(I,J+1)-R(I,J-1))/(t(J+1)-t(J-1))*R(I,J);
        dV7dt(I,J) = (V(I,J+1)-V(I,J-1))/(t(J+1)-t(J-1));
    end
    % reverse difference for the final point
    % RdR7dt(I,end) = (R(I,end)-R(I,end-1))/(t(end)-t(end-1))*R(I,end);
    dV7dt(I,end) = (V(I,end)-V(I,end-1))/(t(end)-t(end-1));
end

% % Normalize volumes
% V7VMean = nan(size(V));
% for I = 1:length(RMean)
%     V7VMean(:,I) = V(:,I)/RMean(I);
% end

% Normalize radii
R7RMean = nan(size(R));
for I = 1:length(RMean)
    R7RMean(:,I) = R(:,I)/RMean(I);
end


%% Plot

if strcmpi('central',p2p) && length(V(1,:)) > 2
    display('Plotting only points from central difference')
    R7RMean = R7RMean(:,2:end-1);
    dV7dt = dV7dt(:,2:end-1);
elseif strcmpi('central',p2p)
    display('Cannot use the central difference; two or less timesteps!')
elseif ~strcmpi('all',p2p)
    display('Options for P2P are: ''all'' and ''central''')
    display('Plotting all')
end

figure; scatter(R7RMean(:),dV7dt(:)); hold on;
% xlim([0 4.5]); ylim([-3e4, 5e4]);
xticks = get(gca,'XTick'); yticks = get(gca,'YTick');
line([xticks(1),xticks(end)],[0,0],'Color','k')
line([1,1],[yticks(1),yticks(end)],'Color','k')
xlabel('$R/\langle R \rangle$','Interpreter','Latex','FontSize',14)
ylabel('$\Delta V/\Delta t$ ($\mu$m$^3$/h)','Interpreter','Latex','FontSize',14)


end

