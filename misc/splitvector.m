function splitX = splitvector( x, numBins )
%splitvector Split vector into approximately equal parts
%
%   splitX = splitvector( x, numBins ) splits the vector (or matrix) x into
%   approximately equal parts. The number of divisions can be specified by
%   numBins. If not provided, histcounts is used to determine this value.
%
%   splitX is a 2D matrix of which the number of columns is equal to
%   numBins. Because the length of x is not always divisible by numBins
%   with no remander, the length of each column can vary. Columns with
%   fewer entries are filled out with NaNs.
%
%   Jules Dake
%   25 Jul 2016
%

% Make x a one dimensional vector
x = x(:);
% Check if number of bins is given
if nargin == 1
   N = histcounts(x);
   numBins = length(N);
end

% Set bin width and initialize variables
binWidth = length(x)/numBins;
splitX = nan(ceil(binWidth),numBins);
I = 0;
loopCounter = 0;
while I < length(x)
    loopCounter = loopCounter + 1;
    indStart = I + 1;
    I = round(loopCounter*binWidth);
    if I > length(x)
        I = length(x);
    end
    indEnd = I;
    splitX(1:indEnd-indStart+1,loopCounter) = x(indStart:indEnd);
end

end

