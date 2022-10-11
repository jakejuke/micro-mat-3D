function fullGTs = sp8_restoreOrs(fullGTs)
%SP8_RESTOREORS Restore original orientations from field 'old'
%   
%   fullGTs = sp8_restoreors(fullGTs) for a structure fullGTs with the
%   field 'old', overwrites field 'orient' with 'old(:,2:4)'
%
%
%   Jules Dake
%   Uni Ulm, 12 Oct 2014
%

for I=1:length(fullGTs)
    fullGTs(I).orient = fullGTs(I).old(:,2:4);
end

end

