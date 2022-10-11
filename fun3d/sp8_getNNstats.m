function fullGTs = sp8_getNNstats(fullGTs, varargin)
%sp8_getNNstats gets misorientation, area and grain labels
%
%   fullGTs = sp8_getNNstats(fullGTs)
%   For each grain in the grain table fullGTs, this function finds all
%   nearest neighbors. The grain table must already have the field
%   fullGTs.gbMat. (Could fix this in a future version.)
%
%   If option 'TexComp' is set, this function also returns the texture
%   component to which its neighbors below. The result looks is a cell
%   fullGTs.nnArea for each grain with entries:
%       row 1: misorientation
%       row 2: texture component (optional)
%       row 3: boundary area
%       row 4: grain label 1
%       row 5: grain label 2
%   
%   To access the nearest neighbor lists in the new grain table, use:
%   fullGTs(I).NN{GOI}, where GOI is the 'grain of interest' and I is the
%   time step index.
%
%   
%   Jules Dake
%   17 Apr 2017, modified on 9 Oct 2017 to add texture component option
%   


%% Parse input variables
p = inputParser;

defaultTexComp = false;

addRequired(p, 'fullGTs', @isstruct);
addParameter(p, 'TexComp', defaultTexComp, @islogical);

parse(p,fullGTs,varargin{:});

TEXCOMP = p.Results.TexComp;


%% Check if field .gbMat exists
if ~isfield(fullGTs,'NN')
    warning('This function required the structure field .NN')
    display('Running sp8_getNN')
    fullGTs = sp8_getNN(fullGTs);
end


%% Set loop variables
numTs = length(fullGTs);
numGs = length(fullGTs(1).labels);


%% Find nearest neighbors for all grains across all time steps
%  If the texture component flag is set, save this relation as well
if TEXCOMP
for I=1:numTs
    fullGTs(I).nnArea{numGs,1} = [];
    display(['Time step ' num2str(I) ' of ' num2str(numTs)])
    % index of fullGTs.gbMat are the grain labels + 1
    gbMat = fullGTs(I).gbMat(2:end,2:end);
    for J=1:numGs
        if isfinite(fullGTs(I).labels(J))
            goi = fullGTs(I).labels(J);
            nn = fullGTs(I).NN{J};
            nn = nn(nn>0);
            misor = zeros(1,length(nn));
            a = zeros(1,length(nn));
            textureComponent = fullGTs(I).phase(nn)';
            for K=1:length(nn)
                misor(K) = calcmisor(fullGTs(I).orient(goi,:),fullGTs(I).orient(nn(K),:));
                a(K) = (gbMat(goi,nn(K)) + gbMat(nn(K),goi))/2;
            end
            fullGTs(I).nnArea{J} = [misor; textureComponent; a;...
                repmat(goi,1,length(nn)); nn];
        end
    end
end

% Otherwise write just misorientation, GB area, grain1, grain2 (old code)
else
for I=1:numTs
    fullGTs(I).nnArea{numGs,1} = [];
    display(['Time step ' num2str(I) ' of ' num2str(numTs)])
    % index of fullGTs.gbMat are the grain labels + 1
    gbMat = fullGTs(I).gbMat(2:end,2:end);
    for J=1:numGs
        if isfinite(fullGTs(I).labels(J))
            goi = fullGTs(I).labels(J);
            nn = fullGTs(I).NN{J};
            nn = nn(nn>0);
            misor = zeros(1,length(nn));
            a = zeros(1,length(nn));
            for K=1:length(nn)
                misor(K) = calcmisor(fullGTs(I).orient(goi,:),fullGTs(I).orient(nn(K),:));
                a(K) = (gbMat(goi,nn(K)) + gbMat(nn(K),goi))/2;
            end
            fullGTs(I).nnArea{J} = [misor; a; repmat(goi,1,length(nn)); nn];
        end
    end
end
end

end
