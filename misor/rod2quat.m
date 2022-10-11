function quat = rod2quat(rod)
%rod2quat Calculates quaternions from Rodrigues values
%   
%   quat = sp8_qcalculate(rod) returns the quaternions for one or more of
%   Rodrigues vectors. Each Rodrigues vector should be a row of 'rod'.
%   
%   Jules Dake
%   24 Nov 2016
%   

% Allocate q for quaternions
quat = nan(size(rod,1),4);

for I=1:size(rod,1)
    if all(isfinite(rod(I,:)))
        quat(I,:) = U2q(r2U(rod(I,:)));
    end
end


end

