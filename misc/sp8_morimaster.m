function moriMaster = sp8_morimaster(fullGTs)
%sp8_sigmaGBs 
%
%   moriMaster = sp8_morimaster(fullGTs)
%
%   Can take a long time...
%   
%   Jules Dake
%   11 Aug 2017
%   

cutOffAngle = 15;
CS = crystalSymmetry('m-3m');
numGs = length(fullGTs(1).labels);


%% Start MTEX if not already running
if ~exist('mtex_path','file')
    wd = pwd;
    cd ~/Documents/MATLAB/mtex-4.3.2/
    startup
    cd(wd)
    clear wd
end


%% Find all grain boundaries and preallocate misor structure
gbMaster = isfinite(fullGTs(1).gbMat(2:end,2:end));
for TS=2:length(fullGTs)
    gbMaster = or(gbMaster, isfinite(fullGTs(TS).gbMat(2:end,2:end)));
end

[I, J] = find(gbMaster); % find seems to flip rows and columns
A = [J, I];
A = removeDuplicates(A);
A( isnan(A(:,1)),: ) = [];
numUniqueGrainPairs = length(A(:,1));

% Preallocate structure moriMaster (misorientation master)
moriMaster(numGs,numGs).axis = [];
moriMaster(numGs,numGs).angle = [];
moriMaster(numGs,numGs).csl = [];


%% Calculate average orientation for grains that exist over multiple times
oAll = cat(3,fullGTs.orient);
for ii=1:numGs
    myOri = squeeze(oAll(ii,:,:))';
    myOri(any(isnan(myOri),2),:) = [];
    for jj=1:size(myOri,1)
        gOri(jj,1) = orientation('matrix', r2U(myOri(jj,:)), CS);
    end
    o(ii,1) = mean(gOri);
    clear gOri
end


%% Calculate misorientation and check CSL conditions
fprintf('Iteration 1 of %i\n',numUniqueGrainPairs)
tic
for ii=1:numUniqueGrainPairs
    m = o( A(ii,1) ).inv * o( A(ii,2) );
    moriMaster(A(ii,1),A(ii,2)).axis = m.axis;
    moriMaster(A(ii,1),A(ii,2)).angle = m.angle/degree;
    
    rotAngle3 = angle(m,CSL(3,CS))/degree;
    rotAngle5 = angle(m,CSL(5,CS))/degree;
    rotAngle7 = angle(m,CSL(7,CS))/degree;
    rotAngle9 = angle(m,CSL(9,CS))/degree;
    rotAngle11 = angle(m,CSL(11,CS))/degree;
    % ...
    
    if rotAngle3 < cutOffAngle/sqrt(3)
        moriMaster(A(ii,1),A(ii,2)).csl = 3;
    elseif rotAngle5 < cutOffAngle/sqrt(5)
        moriMaster(A(ii,1),A(ii,2)).csl = 5;
    elseif rotAngle7 < cutOffAngle/sqrt(7)
        moriMaster(A(ii,1),A(ii,2)).csl = 7;
    elseif rotAngle9 < cutOffAngle/sqrt(9)
        moriMaster(A(ii,1),A(ii,2)).csl = 9;
    elseif rotAngle11 < cutOffAngle/sqrt(11)
        moriMaster(A(ii,1),A(ii,2)).csl = 11;
    else
        moriMaster(A(ii,1),A(ii,2)).csl = 0;
    end
    
    if mod(ii,floor(numUniqueGrainPairs/20)) == 0
        fprintf('Iteration %i of %i\n',ii,numUniqueGrainPairs)
        toc
    end
end


%% Write NaN's in empty spaces and remove MTEX 'miller' objects
%  - allows to convert to matrices and
%  - allows user to run without MTEX
for ii=1:size(moriMaster,1)
    for jj=1:size(moriMaster,2)
        if isempty(moriMaster(ii,jj).angle)
            moriMaster(ii,jj).axis = [NaN, NaN, NaN];
            moriMaster(ii,jj).angle = NaN;
            moriMaster(ii,jj).csl = NaN;
        else
            moriMaster(ii,jj).axis = moriMaster(ii,jj).axis.hkl;
        end
    end
end


end


% Subfunction: Remove duplicate rows from a matrix A
function A = removeDuplicates(A)

g_left2right = A(:,1)*10000 + A(:,2);
g_right2left = A(:,2)*10000 + A(:,1);

duplicates = g_left2right(ismember(g_left2right, g_right2left));

for ii=1:length(duplicates)
    if isfinite(duplicates(ii))
        g1 = floor(duplicates(ii)/10000);
        g2 = mod(duplicates(ii),10000);
        gFlipped = g2*10000 + g1;
        
        duplicates(duplicates==gFlipped) = NaN;
        A(g_left2right==gFlipped,:) = NaN;
    end
end
end


