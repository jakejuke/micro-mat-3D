function newGT = sp8_makefullGT(A, origGT)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

newGT.labels = origGT.labels;
newGT.orient = origGT.orient;
newGT.old = origGT.old;
newGT.centroid = nan(length(newGT.labels),3);
newGT.volume = nan(length(newGT.labels),1);
newGT.gradius = nan(length(newGT.labels),1);

s = regionprops(A);

for I=1:length(s)
    %
    if s(I).Area > 0
        newGT.centroid(newGT.labels==I,:) = s(I).Centroid;
        newGT.volume(newGT.labels==I) = s(I).Area;
        newGT.gradius(newGT.labels==I) = (3*s(I).Area/(4*pi))^(1/3);
    end
end

end

