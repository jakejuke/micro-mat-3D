function fullGTs = sp8_getNN(fullGTs)
%SP8_GETNN add the field 'nearest neighbors' to an sp8 grain table
%
%   fullGTs = sp8_getNN(fullGTs)
%   For each grain in the grain table fullGTs, this function finds all
%   nearest neighbors. The grain table must already have the field
%   fullGTs.gbMat. (Could fix this in a future version.)
%   
%   To access the nearest neighbor lists in the new grain table, use:
%   fullGTs(I).NN{GOI}, where GOI is the 'grain of interest' and I is the
%   time step index.
%
%   
%   Jules Dake
%   Uni Ulm, 4 Dec 2015
%   

%% Check if field .gbMat exists
if ~isfield(fullGTs,'gbMat')
    warning('This function required the structure field .gbMat')
    error('Run sp8_gbAreaMat first')
end

%--- Could add this in the future ---%
% if ~isfield(fullGTs,'gbMat')
%     %get gbMat's
%     for I=1:length(fullGTs)
%     bMat = sp8_gbAreaMat(voxlist{I},fullGTs(I));
%     fullGTs(I).gbArea = bMat(1,2:end)';
%     fullGTs(I).gbMat = bMat;
%     end
% end


%% Set loop variables
numTs = length(fullGTs);
numGs = length(fullGTs(1).labels);


%% Find nearest neighbors for all grains across all time steps
for I=1:numTs
    NN = cell(numGs,1);
    for J=1:numGs
        if isfinite(fullGTs(I).labels(J))
            goi = fullGTs(I).labels(J);
            % index of fullGTs.gbMat are the grain labels + 1
            %  -> find neighbors w/ shared area
            NN{J} = find(isfinite(fullGTs(I).gbMat(goi+1,:))) - 1;
        end
    end
    fullGTs(I).NN = NN;
    clear NN
end

end
