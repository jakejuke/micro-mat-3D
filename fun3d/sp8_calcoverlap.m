function ovlpMat = sp8_calcoverlap(A, B, sizeAB)
%SP8_CALCOVERLAP Calculate the overlap of grains in the linear vectors A, B
%   A is a linear vector with unique grain numbers
%
%   B is a linear vector with unique grain numbers from another timestep
%
%   sizeAB is the [max(A) max(B)]; by letting the user specify this, it can
%   be bigger than the maximum of the two vectors provided by the user.
%
%   By Jules Dake, Uni Ulm, Germany
%   Jan 2014

%% Check user input

if length(A)~=length(B)
    error('length of A must be equal to length of B')
end

if nargin == 2
    ovlpMat = zeros(max(A),max(B));
elseif nargin == 3
    ovlpMat = zeros(sizeAB);
else
    display('Wrong number of input arguments')
    display('Usage:')
    display('ovlpMat = sp8_calcOverlap(A, B)')
    display('ovlpMat = sp8_calcOverlap(A, B, sizeAB)')
    return
end

%% Main code

% I could just go from 1:max(A), but this might be faster if there is not a
% lot of overlap. In my stitching case, A & B only have nonzero elements
% where they overlap near the stitch
unique_in_A = unique(A);

% don't want to know the overlap with zero
% check only unique_in_A(1) because output is sorted
if unique_in_A(1) == 0
    unique_in_A = unique_in_A(2:end);
end

for I=1:length(unique_in_A)
    %
    Bp = B(A==unique_in_A(I));
    unique_in_Bp = unique(Bp);
    % again, don't want to know the overlap with zero
    if unique_in_Bp(1) == 0
        unique_in_Bp = unique_in_Bp(2:end);
    end
    for J=1:length(unique_in_Bp)
        %
        ovlpMat(unique_in_A(I),unique_in_Bp(J)) = nnz(Bp==unique_in_Bp(J));
    end
end

end

