function [binCenters, N, x] = sp8_misorhisto(fullGT,varargin)
%sp8_misorhisto calculate (weighted) misorientation distribution
%   
%   [binCenters,N] = sp8_misorhisto(fullGT,varargin)
%   
%   Options: 'BinWidth' - default 2.5
%            'BinMax' - default 63
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
defaultBinMax = NaN;
addParameter(p,'BinMax',defaultBinMax,@isnumeric);
% Actually only checks for 'Area' in the code..
defaultWeight = 'Number';
addParameter(p,'Weight',defaultWeight,@ischar);

parse(p,fullGT,varargin{:});
binwidth = p.Results.BinWidth;
binmax = p.Results.BinMax;
method = p.Results.Weight;


%% Find GB relations
x = nan(nnz(isfinite(fullGT.gbMat(2:end,2:end))),3);
y = nan(nnz(isfinite(fullGT.gbMat(2:end,2:end))),1);
index = 0;

% exclude 'bad grains' if any
if isfield(fullGT,'badGrain')
    display('Removing ''bad'' grains from calculation')
    fullGT.labels(fullGT.badGrain) = NaN;
else
    display('No ''bad'' grains removed from calculation')
end

goodGrains = fullGT.labels(isfinite(fullGT.labels));

for I=1:length(goodGrains)
    GOI = goodGrains(I);
    NNs = find(isfinite(fullGT.gbMat(GOI+1,:))) - 1;
    NNs = NNs(NNs > 0);
    
    for J=1:length(NNs)
        index = index + 1;
        x(index,1) = GOI;
        x(index,2) = NNs(J);
        x(index,3) = mymisorientation(fullGT.orient(GOI,:),...
            fullGT.orient(NNs(J),:));
        if strcmpi(method,'Area')
            y(index) = fullGT.gbMat(GOI+1,NNs(J)+1);
        else
            y(index) = 1;
        end
        
    end
end
% Get rid of NaNs; vectors were extra long
x = x(1:index,:);
misor = x(:,end);
y = y(1:index);
y = y/sum(y);


%% Calculate normalized distributions (PDFs)
if isnan(binmax)
    binmax = ceil(max(misor));
end
edges = (binwidth:binwidth:binmax)';
binCenters = edges - binwidth/2;
N = nan(length(edges),1);

N(1) = sum(y(misor<edges(1)));

for I=2:length(edges)
    %
    N(I) = sum(y(and((misor>=edges(I-1)),(misor<edges(I)))));
end

% normalize the total area (sum of binHeight*binWidth) to be one
N = N/binwidth;

end

