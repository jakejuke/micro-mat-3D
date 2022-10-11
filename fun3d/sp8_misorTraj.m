function [gbMisorCompact, gbPairsCompact, gbMisor, gbPairs] = sp8_misorTraj( fullGTs )
%sp8_misorTraj Track boundary misorientations vs time
%
%   [gbMisorCompact, gbPairsCompact, gbMisor, gbPairs] = ...
%       sp8_misorTraj( fullGTs )
%
%   Jules Dake
%   21 May 2016
%

numGs = length(fullGTs(1).labels);
numts = length(fullGTs);
gbMats = nan([size(fullGTs(1).gbMat(2:end,2:end)), numts]);

% Stack gbMats to make 3D matrix
for t=1:numts
    gbMats(:,:,t) = fullGTs(t).gbMat(2:end,2:end);
end

% % Remove 'bad' grains if field exists
% % check if there are 'bad grains' that should be excluded
% if isfield(fullGTs,'badGrain')
%     display('Removing ''bad'' grains from misor matrix')
%     badGrainIndex = sp8_excludeBadGrains(fullGTs);
%     gbMats(badGrainIndex,:,:) = NaN;
%     gbMats(:,badGrainIndex,:) = NaN;
% else
%     display('No ''bad'' grains')
% end

% The number of unique entries in the symmetric gbMat matrix is:
maxGBs = (numGs^2 - numGs)/2;
gbMisor = nan( maxGBs, length(fullGTs) );
gbPairs = nan( maxGBs, 3);


%% Misorientation trajectories
linIndx = 0;
% Loop through unique entries of gbMat matrix looking forward in time (the
% third dimension) to track the misorientation of all boundaries across
% time
for I=1:numGs
    for J=1:I-1
        % fprintf('(%d,%d)\n',I,J)
        linIndx = linIndx + 1;
        for t=1:numts
            if isfinite( gbMats(I,J,t) )
                % fprintf('(%d,%d,%d)\n',I,J,t)
                gbMisor(linIndx,t) = calcmisor(fullGTs(t).orient(I,:),...
                    fullGTs(t).orient(J,:));
                gbPairs(linIndx,:) = [I, J, t];
            end
        end
    end
end
gbMisorCompact = gbMisor(any(isfinite(gbMisor),2),:);
gbPairsCompact = gbPairs(any(isfinite(gbPairs),2),:);


end