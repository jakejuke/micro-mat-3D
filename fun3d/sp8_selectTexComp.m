function [ newGTs, new3Ds ] = sp8_selectTexComp( phase, fullGTs, full3Ds )
%sp8_selectTexComp Selects grains of a given texture component
%
%   newGTs = sp8_selectTexComp(phase,fullGTs) selects grains of a certain
%   texture component defined by the input argument phase, which should be
%   a logical array equal in length to the number of entries in
%   fullGTs.labels, and creates a new structure (newGTs) from fullGTs. This
%   new grain table only contains grains where phase is true.
%
%
%   30 Nov 2016
%   Jules Dake


% Check inputs for type and dimensions
if ~islogical(phase)
    error('Expected a logical array, not a %s.', class(phase))
end
if length(phase) ~= length(fullGTs(1).labels)
    error('Dimensions mismatch.')
end

% Create new grain table structure
sFields = fieldnames(fullGTs);
for TS=1:length(fullGTs)
    for F=1:length(sFields)
        currentField = sFields{F};
        if length(fullGTs(TS,1).(currentField)) == length(phase)
            newGTs(TS,1).(currentField) = fullGTs(TS,1).(currentField)(phase);
        else
            newGTs(TS,1).(currentField) = fullGTs(TS,1).(currentField);
        end
    end
    % Set .phase entry of grains which have disappeared to NaN
    newGTs(TS,1).phase( isnan(newGTs(TS,1).labels) ) = NaN;
end

% If three input variables are supplied, return 3D matrix with grains of
% given texture component
if nargin == 3
    new3Ds = full3Ds;
    for TS=1:length(fullGTs)
        labels = newGTs(TS).labels;
        labels(isnan(labels)) = [];
        % Set are grains to zero (black) that don't belong to texture comp.
        new3Ds{TS}( ~ismember(new3Ds{TS},labels) ) = 0;
    end
end

end

