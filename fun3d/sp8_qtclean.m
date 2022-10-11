function GT = sp8_qtclean(GT)
%SP8_QTCLEAN Quick Track Clean
%
%   GT = SP8_QTCLEAN(GT) cleans a grain table of multiple matches during
%   tracking. If multiple grains in a given timestep are matched to a
%   single grain in the previous timestep, all matches are removed. In
%   doing so they will be reviewed during manual tracking.
%
%   
%   Jules Dake
%   Uni Ulm, 10.10.2014
%


uGNums = unique(GT.tklabels(isfinite(GT.tklabels)));
counts = histc(GT.tklabels(isfinite(GT.tklabels)),uGNums);

% If multiple grains are tracked to the same parent grain, delete these
% matches so that the user must manually track here
if any(counts > 1)
    g = uGNums(counts > 1);
    
    for I=1:length(g)
        display('Removing matches for grains:')
        display(num2str(GT.labels(GT.tklabels==g(I))))
        display(['They were matched to grain ' num2str(g(I))])
        GT.tklabels(GT.tklabels==g(I)) = NaN;
    end
end

end

