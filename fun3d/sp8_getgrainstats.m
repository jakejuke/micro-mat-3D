function [gStats, trackmat] = sp8_getgrainstats(fullGTs)
%SP8_GETGRAINSTATS Makes a struct containing grain statistics
%   The length of the structure is equal to the number of grains in the
%   initial timestep. Values (fields) for each grain are: labels, orient,
%   regorient, volume, and gradius.
% 
% 
%   EXAMPLE:
%       gStats = sp8_getgrainstats(fullGTs);
%
%   INPUT:
%       fullGTs - a struct containing tracking information for each
%       timestep
%   
%   OUTPUT:
%       gStats - Nx1 struct, where N is the initial number of grains
% 
% 
%   Jules Dake, Uni Ulm
%   June 2014
% 


gStats = initgrainstats(fullGTs);
% check if grain tracking has been done; if not assumes grains have proper
% labels over all timesteps
if isfield(fullGTs,'tklabels')
    trackmat = maketrackmat(fullGTs);
else
    trackmat = maketrackmat2(fullGTs);
end
% [gStats(1:end).labels] = trackmat(1:end,:);

numGrains = length(fullGTs(1).labels);
numTimeSteps = length({fullGTs.timestep});

for I = 1:numTimeSteps
    for J = 1:numGrains
        gNum = trackmat(J,I);
        if isfinite(gNum)
            gStats(J).labels(I) = gNum;
            gStats(J).orient(I,:) = ...
                fullGTs(I).orient(fullGTs(I).labels==gNum,:);
            % gStats(J).regorient(I,:) = ...
            %     fullGTs(I).tkregorient(fullGTs(I).labels==gNum,:);
            gStats(J).volume(I) = ...
                fullGTs(I).volume(fullGTs(I).labels==gNum,:);
            gStats(J).gradius(I) = ...
                fullGTs(I).gradius(fullGTs(I).labels==gNum,:);
        end
    end
end

% display('done')

end



%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%

function gStats = initgrainstats(fullGTs)
% Initializes the grain statistics (gStats) matrix

a = length(fullGTs);
% fields are:
fd1 = 'labels'; v1 = nan(1,a);
% fd2 = 'orient'; v2{1} = nan(1,3); v2 = repmat(v2,1,a);
% fd3 = 'regorient'; v3{1} = nan(1,3); v3 = repmat(v3,1,a);
fd2 = 'orient'; v2 = nan(a,3);
fd3 = 'regorient'; v3 = nan(a,3);
fd4 = 'volume'; v4 = nan(1,a);
fd5 = 'gradius'; v5 = nan(1,a);
% fd6 = '';
% fd7 = '';
% fd8 = '';
% fd9 = '';

gStats = struct(fd1,{v1},fd2,{v2},fd3,{v3},fd4,{v4},fd5,{v5});
gStats = repmat(gStats, length(fullGTs(1).labels), 1);

end


function trackmat = maketrackmat(fullGTs)
% Makes the maxtrix used to track labels (trackmat)

trackmat = nan(length(fullGTs(1).labels),length(fullGTs));
trackmat(:,1) = fullGTs(1).labels;

for I=2:length(fullGTs)
    for J=1:length(fullGTs(I).tklabels)
        % row:    trackmat(:,I-1)==fullGTs(I).tracklabels(J)
        % column: I
        trackmat(trackmat(:,I-1)==fullGTs(I).tklabels(J),I) = ...
            fullGTs(I).labels(J);
    end
end

end

function trackmat = maketrackmat2(fullGTs)
% Makes the maxtrix used to track labels (trackmat)

trackmat = fullGTs(1).labels;
trackmat = repmat(trackmat,1,length(fullGTs));

for I=2:length(fullGTs)
    trackmat(~ismember(trackmat(:,I),fullGTs(I).labels),I) = NaN;
end

end