function full3D = sp8_mantracksetup(full3D, fullGT)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

grainsFound = fullGT.labels(isfinite(fullGT.tracklabels));

for I=1:length(grainsFound)
    %
    full3D(full3D==grainsFound(I)) = 0;
end

end

