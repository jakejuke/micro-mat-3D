function newGT = sp8_sigmaGBs(fullGT)
%sp8_sigmaGBs 
%
%   sp8_misor_v_sampleR(fullGT)
%
%   
%   Jules Dake
%   29 Jul 2017
%   

cutOffAngle = 15;


%% Start MTEX if not already running
if ~exist('mtex_path','file')
    wd = pwd;
    cd ~/Documents/MATLAB/mtex-4.3.2/
    startup
    cd(wd)
    clear wd
end


%% Add field sigmaGBs to the structure fullGT
if ~isfield(fullGT,'sigmaGBs')
    gbMat = fullGT.gbMat(2:end,2:end);
    sizeGBMat = size(gbMat);
    sigmaGBs = nan(sizeGBMat);
    I = find(isfinite(gbMat));
    CS = crystalSymmetry('m-3m');
    
    for grainPair = 1:length(I)
        [gInd1,gInd2] = ind2sub(sizeGBMat,I(grainPair));
        U1 = r2U(fullGT.orient(gInd1,:));
        U2 = r2U(fullGT.orient(gInd2,:));
        
        o1 = orientation('matrix',U1,CS);
        o2 = orientation('matrix',U2,CS);
        
        mori = o1.inv * o2;
        
        rotAngle3 = angle(mori,CSL(3,CS))/degree;
        rotAngle5 = angle(mori,CSL(5,CS))/degree;
        rotAngle7 = angle(mori,CSL(7,CS))/degree;
        rotAngle9 = angle(mori,CSL(9,CS))/degree;
        rotAngle11 = angle(mori,CSL(11,CS))/degree;
        
        if rotAngle3 < cutOffAngle/sqrt(3)
            sigmaGBs(gInd1,gInd2) = 3;
        elseif rotAngle5 < cutOffAngle/sqrt(5)
            sigmaGBs(gInd1,gInd2) = 5;
        elseif rotAngle7 < cutOffAngle/sqrt(7)
            sigmaGBs(gInd1,gInd2) = 7;
        elseif rotAngle9 < cutOffAngle/sqrt(9)
            sigmaGBs(gInd1,gInd2) = 9;
        elseif rotAngle11 < cutOffAngle/sqrt(11)
            sigmaGBs(gInd1,gInd2) = 11;
        end
        %if grainPair == 2078
        %    break
        %end
        if mod(grainPair,floor(length(I)/20)) == 0
            fprintf('Iteration %i of %i\n',grainPair,length(I))
        end 
    end
    newGT = fullGT;
    newGT.sigmaGBs = sigmaGBs;
else
    display('The field sigmaGBs already exists')
end


end

