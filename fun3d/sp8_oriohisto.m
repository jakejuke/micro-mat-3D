function [binCenters,N] = sp8_oriohisto(fullGT,varargin)
%sp8_oriohisto calculates orientation distribution for given timestep
%   
%   [binCenters,N] = sp8_oriohisto(fullGT,varargin)
%
%   
%   Jules Dake
%   Uni Ulm, 16 Oct 2014
%


%% Parse input variables

p = inputParser;

% required parameters
addRequired(p,'fullGT',@isstruct);
% optional parameters
defaultBinWidth = 2.5;
addParameter(p,'BinWidth',defaultBinWidth,@isnumeric);
defaultBinMax = 63;
addParameter(p,'BinMax',defaultBinMax,@isnumeric);
% parse
parse(p,fullGT,varargin{:});
binwidth = p.Results.BinWidth;
binmax = p.Results.BinMax;


%%  Calculate single-value orientation for each grain

% exclude 'bad grains' if any
if isfield(fullGT,'badGrain')
    display('Removing ''bad'' grains from calculation')
    fullGT.labels(fullGT.badGrain) = NaN;
else
    display('No ''bad'' grains removed from calculation')
end

goodOrients = fullGT.orient(isfinite(fullGT.labels),:);
y = nan(length(goodOrients),1);

for I=1:length(goodOrients)
    y(I) = mymisorientation(goodOrients(I,:),[0 0 0]);
end


%%
% edges = ((0:2.5:63)+2.5/2)';
edges = (binwidth:binwidth:binmax)';
binCenters = edges - binwidth/2;
N = nan(length(edges),1);

% count number of elements in each bin
% same as: N = hist(y,binCenters);
N(1) = sum(y<edges(1));
for I=2:length(edges)
    N(I) = sum(and((y>=edges(I-1)),(y<edges(I))));
end

% normalize the total area (sum of binHeight*binWidth) to be one
N = N/(sum(N)*binwidth);

end

