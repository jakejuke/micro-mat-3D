function [meanNN, minNN, maxNN, numNN] = sp8_numNN( fullGTs )
%SP8_numNN finds statistics on the number or nearest neighbors
%   
%   [meanNN, minNN, maxNN, numNN] = numNN( fullGTs ) accepts the
%   multidimensional structure fullGTs and returns the mean, minimum and
%   maximum number of nearest neighboring grains.
%   
% Jules Dake
% 16 May 2016
%

% Get nearest neighbors
if ~isfield(fullGTs,'NN')
    fullGTs = sp8_getNN(fullGTs);
end

numNN = nan(length(fullGTs(1).labels),length(fullGTs));
for I=1:length(fullGTs)
    for J=1:length(fullGTs(I).labels)
        if ~fullGTs(I).surfGrain(J) && isfinite(fullGTs(I).labels(J))
            numNN(J,I) = length(fullGTs(I).NN{J});
        end
    end
end

meanNN = nanmean(numNN);
minNN = nanmin(numNN);
maxNN = nanmax(numNN);

end
