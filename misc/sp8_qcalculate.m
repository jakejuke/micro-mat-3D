function q = sp8_qcalculate(fullGTs)
%sp8_qcalculate Calculates quaternions from Rodrigues values
%   
%   q = sp8_qcalculate(fullGTs) returns the quaternions for each timestep
%   of the grain table fullGTs. The function excludes "Bad Grains" if it
%   finds the label in fullGTs. First converts the Rodrigues vectors to the
%   U matrix notation and then uses U2q.m to convert to quaternions.
%   
%   
%   Jules Dake
%   Uni Ulm, 11 Mar 2015
%   

% allocate q for quaternions
q = cell(length(fullGTs),1);


%% Check if field 'bad grains'
if ~isfield(fullGTs,'badGrain')
    error('MATLAB:nonExistentField', ...
        '\tField ''badGrain'' not found\n\tRun sp8_removeTBgrains.m first')
end


%% Convert
for I=1:length(fullGTs) % for each timestep
    q{I} = nan(length(fullGTs(I).labels),4);
    for J=1:length(fullGTs(I).labels) % and each good grain
        if isfinite(fullGTs(I).labels(J)) && ~fullGTs(I).badGrain(J)
            U = r2U(fullGTs(I).orient(J,:));
            q{I}(J,:) = U2q(U);
        end
    end
end

if length(fullGTs) == 1
    q = cell2mat(q);
end

end

