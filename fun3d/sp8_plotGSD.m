function hc = sp8_plotGSD(GTs,voxSize,varargin)
%sp8_plotGSD Calculates (and plots) grain size distributions
%   
%   hc = sp8_plotGSD(GTs,voxSize) calculates normalized grain size
%   distributions for the data in grain tables (GTs). The voxel size
%   voxSize must be specified by the user. Returns hc, which is a structure
%   containing the counts for each bin, the bin edges and bin centers.
%   
%   hc = sp8_plotGSD(...,'Normalize',true/false) sets the normalization
%   option, default is true. When true, the x-axis is normalized as
%   (R/mean(R)).
%   
%   hc = sp8_plotGSD(...,'Plot',true/false) sets the plot option, default
%   is true. If false, no plot is generated, just the values.
%   
%   hc = sp8_plotGSD(...,'BinWidth',value) allows the user to set a numeric
%   value for the bin width.
%   
%   
%   Jules Dake
%   Uni Ulm, 18 Apr 2016


%% Parse input variables
p = inputParser;
defaultNormalize = true;
defaultPlot = true;
defaultBinWidth = NaN;

addRequired(p,'GTs',@isstruct);
addRequired(p,'voxSize',@isnumeric);
addParameter(p,'Normalize',defaultNormalize,@islogical);
addParameter(p,'Plot',defaultPlot,@islogical);
addParameter(p,'BinWidth',defaultBinWidth,@isnumeric);

parse(p,GTs,voxSize,varargin{:});
xNorm = p.Results.Normalize;
plotVar = p.Results.Plot;
bWidth = p.Results.BinWidth;


%% Create histogram data in 2-step process using histcounts
g = cell(size(GTs));
hc = struct('N',[],'edges',[],'x',[]);
binWidth = nan(size(GTs));
% Find default bin widths and take median value
for I=1:length(GTs)
    g{I} = voxSize*GTs(I).gradius(isfinite(GTs(I).gradius));
    if xNorm
        g{I} = g{I}/mean(g{I});
    end
    [~, edges] = histcounts(g{I},'Normalization','pdf');
    binWidth(I) = median(diff(edges));
end
% Set bin width and count again
if isnan(bWidth)
    binWidth = median(binWidth);
else
    binWidth = bWidth;
end
for I = 1:length(GTs)
    [N, edges] = histcounts(g{I},'BinWidth',binWidth,'Normalization','pdf');
    hc(I).N = N; hc(I).edges = edges;
    hc(I).x = hc(I).edges(1:end-1) + diff(hc(I).edges)/2;
end


%% Plot
if plotVar
%     c = {'k-^','r-+','b-o','m-x','g-s','c-d'};
    c = {'k-','r-','b-','m-','g-','c-'};
    for I = 1:length(hc)
%         p = plot(hc(I).x,hc(I).N,c{mod(I-1,length(c))+1},'MarkerSize',3,'LineWidth',1);
        p = plot(hc(I).x,hc(I).N,c{mod(I-1,length(c))+1},'LineWidth',0.5);
        p.Color(4) = .4;
        if I == 1
            hold on
        end
    end
    xlabel('$R/\langle R\rangle$','Interpreter','Latex')
    ylabel('frequency')
end

end

