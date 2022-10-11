function rMeanLoc = sp8_rMeanLoc( fullGTs, varargin )
%SP8_RMEANLOC Calculates mean local grain radius
%   This function calculates the mean local grain radius for all grains in
%   the full grain table (fullGTs). Only the nearest neighbors (voxels in
%   contact) go into the calculation.
%   
%   Inputs:
%      fullGTs - grain tables containing grain radius, and annealing times
%
%   Optional Inputs:
%    'VoxSize' - voxel size (default value 1)
%        'GOI' - include or exclude the grain of interest (GOI) in the
%                calculation of rMeanLoc (def 'exclude')
%     'Weight' - The local mean grain size can be weighted by the 'number'
%                of neighbors (arithmetic mean) or by the GB 'area'.
%                Default is 'number'.
%   
%   Outputs:
%       rMeanLoc - local mean radius
%
%   Examples:
%       rMeanLoc = sp8_rdrdt(fullGTs,'VoxSize',5);
%       
%   
% Jules Dake
% Uni Ulm, 22 Apr 2016
% Updated: 22 Sep 2016
% 


%% Parse input variables
p = inputParser;
% required parameters
addRequired(p,'fullGTs',@isstruct);
% optional parameters
defVoxSize = 1;
defGOI = 'exclude';
defWeight = 'number';
% test input pairs
addParameter(p,'VoxSize',defVoxSize,@isnumeric);
addParameter(p,'GOI',defGOI,@ischar);
addParameter(p,'Weight',defWeight,@ischar);
% parse input
parse(p,fullGTs,varargin{:});
vs = p.Results.VoxSize;
exGOI = p.Results.GOI;
weight = p.Results.Weight;


%% Find GB relations
rMeanLoc = nan( length(fullGTs(1).labels), length(fullGTs) );

if strcmpi(weight,'number')
% Look through all grains at all time steps
for I=1:length(fullGTs)
    for J=1:length(fullGTs(I).labels)
        GOI = fullGTs(I).labels(J);
        if isfinite(GOI)
            NNs = find(isfinite(fullGTs(I).gbMat(GOI+1,:))) - 1;
            NNs = NNs(NNs > 0);
            if strcmpi(exGOI,'exclude')
                NNIndex = ismember(fullGTs(I).labels,NNs);
            elseif strcmpi(exGOI,'include')
                NNIndex = ismember(fullGTs(I).labels,[NNs, GOI]);
            else
                error('Bad input for option GOI')
            end
            rMeanLoc(J,I) = mean(fullGTs(I).gradius(NNIndex))*vs;
        end
    end
end

elseif strcmpi(weight,'area')
% Look through all grains at all time steps
for I=1:length(fullGTs)
    for J=1:length(fullGTs(I).labels)
        GOI = fullGTs(I).labels(J);
        if isfinite(GOI)
            NNs = find(isfinite(fullGTs(I).gbMat(GOI+1,:))) - 1;
            NNs = NNs(NNs > 0);
            if strcmpi(exGOI,'exclude')
                NNIndex = ismember(fullGTs(I).labels,NNs);
            elseif strcmpi(exGOI,'include')
                NNIndex = ismember(fullGTs(I).labels,[NNs, GOI]);
            else
                error('Bad input for option GOI')
            end
            % Find average GB area (of internal interfaces only)
            % NOTE: There are two values for GB area because this value is
            % determined twice for each grain; two grains make one boundary
            if isempty(NNs)
                fprintf('Grain: %i of time step: %s has no neighbors\n',...
                    GOI,fullGTs(I).timestep)
            else
                AA = mean([fullGTs(I).gbMat(GOI+1,NNs+1);...
                    fullGTs(I).gbMat(NNs+1,GOI+1)']);
                Radii = fullGTs(I).gradius(NNIndex)*vs;
                rMeanLoc(J,I) = sum(AA.*Radii')/sum(AA);
            end
        end
    end
end
else
    error('Optional input Weight set wrong')
end

end

