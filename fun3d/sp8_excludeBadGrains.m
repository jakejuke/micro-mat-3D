function badGrainIndex = sp8_excludeBadGrains(fullGTs)
%sp8_excludeBadGrains Makes a 'bad' grain index list
%   
%   badGrainIndex = sp8_excludeBadGrains(fullGTs) using the field
%   'badGrain' in fullGTs, this function finds all bad grain labels and
%   combines them, using any(), to make a single column index of bad
%   grains.
%   
%   
%   Jules Dake
%   Uni Ulm, 25 Nov 2014
%   


% check if there are 'bad grains' that should be excluded
if isfield(fullGTs,'badGrain')
    badGrains = horzcat(fullGTs.badGrain);
    badGrainIndex = any(badGrains,2);
    display(['Found ' num2str(nnz(badGrainIndex))...
        ' ''bad'' grains at top/bottom of sample'])
else
    display('Field ''badGrain'' does not exist')
    display('Run sp8_removeTBgrains.m first')
end

end

