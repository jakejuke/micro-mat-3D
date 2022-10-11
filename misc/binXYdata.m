function [ M, MX, STD, N ] = binXYdata( X, Y, EDGES, varargin )
%binXYdata Bins data of x,y scatter plots
%
%   [ M, MX, STD, N ] = binXYdata( X, Y, EDGES ) bins data from a scatter
%   plot. Bins are taken along the x-axis, and for each bin the mean
%   y-value M is calculated. MX is the bin's center. STD is the standard
%   diviation about the mean M, and N is the number of data points in each
%   bin, i.e. the number of values that go into the calculation of the
%   mean.
%
%   Similar to histcounts, bins Y(i) data for edges(k) <= X(i) < edges(k+1)
%
%   Jules Dake
%   24 Jul 2016


%% Check inputs
if nargin < 2
    error('Requires at least two input variables')
elseif nargin == 2
    [N,EDGES] = histcounts(X);
elseif nargin == 3
    [N,EDGES] = histcounts(X,EDGES);
else
    p = inputParser;
    addRequired(p,'X',@isnumeric);
    addRequired(p,'Y',@isnumeric);
    addRequired(p,'EDGES',@isnumeric);
    % optional parameters
    defBinWidth = 5;
    addParameter(p,'BinWidth',defBinWidth,@isnumeric);
    %
    parse(p,X,Y,EDGES,varargin{:});
    BinWidth = p.Results.BinWidth;
    
    [N,EDGES] = histcounts(X,'BinWidth',BinWidth);
end





%% Calculate mean and std
M = nan(length(N),1);
MX = (EDGES(1:end-1) + diff(EDGES)/2)';
STD = nan(length(N),1);
for I = 1:length(N)
    IND = X >= EDGES(I) & X < EDGES(I+1);
    M(I) = nanmean( Y(IND) );
    STD(I) = nanstd( Y(IND) );
end

end
