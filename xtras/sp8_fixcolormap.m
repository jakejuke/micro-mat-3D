function cmap = sp8_fixcolormap(A, colormap)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if sum(colormap(1,:))
    I = (1:length(colormap))';
else
    I = (2:length(colormap))';
    I = [0; I];
end

colormap = [I, colormap];

colormap(~ismember(I(:,1),A(:)),:) = 0;
cmap = colormap(:,2:end);

end

