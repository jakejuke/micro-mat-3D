function tkGT = sp8_mantrackloop(A0,A,GT0,tkGT)
%SP8_MANTRACKLOOP Loops through untracked grains and asks user for labels
%
%   tkGT = SP8_MANTRACKLOOP(A0,A,GT0,tkGT) loops through all the untracked
%   grains in tkGT (tracked Grain Table) and displays three cross sections
%   through the center of mass for each untracked grain (xy, yz, xz) in
%   both the current and previous timesteps.
%   Inputs: A0   - 3D matrix of previous timestep
%           A    - 3D matrix of current timestep
%           GT0  - Previous timestep's grain table
%           tkGT - Current timestep's grain table (must have field
%                  'tklabels')
%   Output: tkGT - Updated grain table for current timestep
%
%
%   Example
%   -------
%   
%       mtkGT = sp8_mantrackloop(reg3Ds{1},reg3Ds{2},fullGTs(1),tkGTs(2))
%
%
%   Jules Dake
%   Uni Ulm, 7 Oct 2014
%

untracked = tkGT.labels(isnan(tkGT.tklabels));

for I=1:length(untracked)
    fprintf(['\nTracking grain ' num2str(untracked(I))])
    
    sp8_mantrack(untracked(I),A0,A,GT0,tkGT,'bwGBs',1)
    uiwait; close all
    
    prompt = {['Enter tracking match for grain ' num2str(untracked(I))]};
    dlg_title = 'ManTracking';
    num_lines = 1;
    def = {'NaN'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    tkLabel = str2num(answer{1});
    fprintf([' -> ' answer{1}])
    if length(tkLabel) > 1
        error('Only one value allowed')
    elseif isnumeric(tkLabel)
        tkGT.tklabels(tkGT.labels==untracked(I)) = tkLabel;
        save('~/Desktop/MOUT_tkTEMP.mat','tkGT')
    else
        warning('No input for grain from user')
    end
end

end

