function relabelledMatrix = relabelGrainMat(grainMatrix)
%relabelGrainMat Relabel grains from 1 to max number of grains
%
%   relabelGrainMat takes a matrix of grain labels and relabels it so the
%   grain numbers are consecutive and span the range of 1 to the maximum
%   number of grains.
%
%   Example:
%       new3D = relabelGrainMat(full3D);
%
%   To do:
%       Add option of relabelling datasets with periodic boundary
%       conditions. This would give grains (of simulations) that are split
%       at the boundaries of the simulation cell (new) unique grain labels.
%
%   Jules Dake
%   Uni Ulm, 24 Oct 2022
%

relabelledMatrix = grainMatrix;

% Get unique grain labels (but ignore label zero)
uniqueGrains = unique(grainMatrix);
uniqueGrains(uniqueGrains==0) = [];

% Relabel grains from 1 to max number of grains
for R=1:length(uniqueGrains)
    relabelledMatrix(grainMatrix==uniqueGrains(R)) = R;
end

end