function fullGTs = sp8_surfgraindetect(full3Ds, fullGTs)
%SP8_SURFGRAINDETECT Detects the Surface Grains of a 3D matrix
%
%   Any grains in contact with the outer surface (value zero in 3D matrix)
%   will be detected and labeled as a surface grain. Pores in the sample
%   interior will not have neighbors identified as surface grains.
%
%   The inputs:
%       full3D - matrix with unique grain numbers
%       fullGT - struct with grain labels and more or less data on those
%                grains (must have at least field: fullGT.labels)
%   
%   The outputs:
%       fullGT - fullGT appended by one field - surfgrain
%                In this field a 1 means surface grain, and zero means
%                interior grain.
%
%   Example:
%       newGT = sp8_rsg(full3D, fullGT)
%       
%
%   Jules Dake, Uni Ulm, Germany
%   June 2014
%

%% Set variables
paddim = 3;     % 3D matrix padded by this number of zeros on all sides
sedim = 3;      % Size of the structuring element (strel)
% create structuring element (cube)
se = strel(ones(sedim,sedim,sedim));

%% Find surface grains
for I=1:length(fullGTs)
    display(['Detecting surface grains for ' fullGTs(I).timestep])
    display(['  timestep ' num2str(I) ' of ' num2str(length(fullGTs))])
    
    % binarize the 3D matrix
    bw = full3Ds{I} > 0;
    % pad with zeros on all sides
    bw = padarray(bw, [paddim paddim paddim]);
    bw2 = imfill(bw,'holes');
    % invert and dilate the outer boundary
    invbw = ~bw2;
    invbwD = imdilate(invbw,se);
    
    % Dilated outer boundary or shell
    shellD = invbwD(1+paddim:end-paddim,1+paddim:end-paddim,...
        1+paddim:end-paddim);
    
    % Labels of Surface GrainS (SGS)
    sgs = unique(full3Ds{I}(shellD));
    sgs = sgs(sgs > 0);
    
    % save surface grains to structure field 'surfGrain'
    fullGTs(I).surfGrain = ismember(fullGTs(I).labels,sgs);
    
end
clear bw bw2 invbw se invbwD shellD sgs

end

