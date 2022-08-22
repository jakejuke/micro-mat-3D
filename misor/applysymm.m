function [Umin, G] = applysymm(U, symmetry)
%applysymm Apply symmetry operations to rotation matrix
%   
%   [Umin, G] = applysymm(U, symmetry) applies symmetry operations to the
%   rotation matrix U for the given symmetry, e.g. 'cubic'
%   
%   Jules Dake
%   Uni Ulm, 13 Sep 2015

G_all = getsymmetry(symmetry);

% Calculate max trace; min rot. angle
max_Tr=0;
for I=1:size(G_all,1)
    % Because 3DXRD seems to use postmultiplication, e.g. A*M = B
    dU = U*squeeze(G_all(I,:,:));
    % Rotation angle given by:
    %     theta = acosd((U(1,1) + U(2,2) + U(3,3) - 1)/2)
    % Thus, the larger the trace, the smaller the angle
    Tr = dU(1,1) + dU(2,2) + dU(3,3);
    if Tr > max_Tr
       max_Tr = Tr;
       Umin = dU;
       G = squeeze(G_all(I,:,:));
    end
end

end
