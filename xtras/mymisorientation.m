function [phi, n, dU, dr, dG] = mymisorientation(a,b,varargin)
%mymisorientation is the same function as calcmisor (kept for historical reasons)
%
%   Determine the misorientation between two Rodrigues vectors (or two
%   orientation matrices) a and b.
%   
%   EXAMPLE:
%       [phi, n, dU, dr, dG] = mymisorientation(r1,r2)
%
%       where phi is the angle of rotation,
%              n  is the axis of rotation,
%             dU  is the misorientation matrix,
%             dr  is the misorientation in Rodrigues notation, &
%             dG  is the symmetry operator which gives the minimum phi
%       
%   OPTIONS:
%       'Symmetry' - can only be 'cubic' right now
%
%   REFERENCES:
%       PhD thesis from Srikanth Patala from MIT
%       Also Engler's book from 2010 (but this is not so good)
%   
%   
%   By Jules Dake, Uni Ulm, Germany.
%   Based on code from Soeren Schmidt, DTU Physics, Denmark. 


%% Parse input variables
p = inputParser;

addRequired(p,'a',@isnumeric);
addRequired(p,'b',@isnumeric);

defSymmetry = 'cubic';
addParameter(p,'Symmetry',defSymmetry,@ischar);

parse(p,a,b,varargin{:});
symmetry = p.Results.Symmetry;


%% Get symmetry relations
if strcmpi(symmetry,'cubic')
    G = getsymmetry(symmetry);
else
    error('Function only works for ''cubic'' symmetry at the moment')
end

% check input a
if length(a(:)) == 3
    A = r2U(a);
elseif length(a(:)) == 9
    A = a;
else
    error('Input should be Rodrigues vecotrs or rotation matrices')
end

% check input b
if length(b(:)) == 3
    B = r2U(b);
elseif length(b(:)) == 9
    B = b;
else
    error('Input should be Rodrigues vecotrs or rotation matrices')
end

% Calculate minimum misorientation by applying symmetry operations
max_Tr=0;
for I=1:size(G,1)
    % Right-handed rotation and coordinate systems, postmultiplication, and
    % M takes A to B: A*G*M = B  -->  M = G'*A'*B (G applys symmetry)
    M = squeeze(G(I,:,:))'*A'*B;
    % Rotation angle given by:
    %     theta = acosd((U(1,1) + U(2,2) + U(3,3) - 1)/2)
    % Thus, the larger the trace, the smaller the angle
    Tr = M(1,1) + M(2,2) + M(3,3);
    if Tr > max_Tr
       max_Tr = Tr;
       dU = M;
       dG = squeeze(G(I,:,:));
    end
end

dr = U2r(dU); % Rodrigues vector
phi = 2.*atand(norm(dr)); % Or: misorientation angle = acosd((max_Tr-1)/2)
n = dr/norm(dr); % normalized misorientation axis

end
