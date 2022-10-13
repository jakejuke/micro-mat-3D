function [full3Ds, fullGTs] = sp8_cleandata(full3Ds, fullGTs)
%SP8_CLEANDATA Cleans 'raw' reconstructed 3DXRD data
%   
%   This function finds the largest connected volume of each grain label
%   and fills any holes in that volume. If there are voxels that are not
%   connected to the largest volume, these are set to zero (I think, I'm
%   writing this description long after writing the function).
%   
%   Some grain parameters (centroid, volume and radius) for each grain are
%   also calculated.
%   
%   
%   EXAMPLE:
%       [full3Ds, fullGTs] = sp8_cleandata(full3Ds, fullGTs);
%   
%
%   Jules Dake, 8 Jun 2014
%   Uni Ulm
%   

% volume cutoff - if the largest region has less than 95% of the total
% volume for a given grain label, then a warning message is displayed
volCut = 0.95;

% FOR all data sets
for lp1=1:length(full3Ds)
    
    display(['regionprops: ' num2str(lp1) ' of ' num2str(length(full3Ds))])
    
    fullGTs(lp1).centroid = nan(length(fullGTs(lp1).labels),3);
    fullGTs(lp1).volume = nan(length(fullGTs(lp1).labels),1);
    fullGTs(lp1).gradius = nan(length(fullGTs(lp1).labels),1);
    
    temp3D = full3Ds{lp1};
    % % CAN'T do this, it would be a better way to fix my indexing problem,
    % %  but I use full3Ds in the code below.... Arrrg.
    % padsize = 1;
    % temp3D = padarray(temp3D,[padsize,padsize,padsize]);
    
    % FOR all grains in each data set
    for lp2=1:length(fullGTs(lp1).labels)
        
        % analyze each grain, pick grain
        BW = full3Ds{lp1}==fullGTs(lp1).labels(lp2);
        
        % REGIONPROPS with PixelList (for multiple conncomp's)
        % S = regionprops(BW,'Area','Centroid','BoundingBox','PixelList');
        S = regionprops(BW,'Area','Centroid','BoundingBox','PixelIdxList');
        
        % if there are multiple connected components, find the largest
        if length(S) > 1
            [~,I] = max([S.Area]);
            for lp3=1:length(S)
                
                if lp3 ~= I
                    % set smaller objects to zero
                    BW(S(lp3).PixelIdxList) = 0;
                else
                    % check relative size of largest object
                    ff = S(I).Area/sum([S.Area]);
                    if ff < volCut
                        display('Multiple large objects!')
                        display(['Grain ' num2str(fullGTs(lp1).labels(lp2)) ...
                            ' in ' fullGTs(lp1).timestep ', ff = ' num2str(ff)])
                    end
                end
            end
            % only keep largest object
            S = S(I,1);
        end
        
        if length(S) == 1
            % cut out largest connected component
            xl = floor(S.BoundingBox(1)); dx = ceil(S.BoundingBox(4));
            yl = floor(S.BoundingBox(2)); dy = ceil(S.BoundingBox(5));
            zl = floor(S.BoundingBox(3)); dz = ceil(S.BoundingBox(6));
            [xl,yl,zl,dx,dy,dz] = ...
                check_indices([xl,yl,zl,dx,dy,dz],size(temp3D));
            BW2 = BW(yl:yl+dy,xl:xl+dx,zl:zl+dz);
            
            % then fill holes
            BW2 = imfill(BW2,'holes');
            % Overwrite BW with 'filled' grain
            BW(yl:yl+dy,xl:xl+dx,zl:zl+dz) = BW2;
            
            % run regionprops again to get "most" accurate calculation of
            % centroid and other props (if there are holes in the grain,
            % they could displace the centroid)
            S = regionprops(BW);
            fullGTs(lp1).centroid(lp2,:) = S.Centroid;
            fullGTs(lp1).volume(lp2) = S.Area;
            fullGTs(lp1).gradius(lp2) = (3*S.Area/(4*pi))^(1/3);
            
            % Write 'filled' grain back to original matrix
            temp3D(BW==1) = lp2;
        else
            % NO GRAIN with this label!!
            display(['Grain ' num2str(lp2) ' in ' fullGTs(lp1).timestep ...
                ' not present in full3D matrix'])
            error('Grain missing')
        end
    end
    % write 'cleaned' matrix back to full3Ds
    full3Ds{lp1} = temp3D;
end

end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%

function [xl,yl,zl,dx,dy,dz] = check_indices(A,matSize)
% This function ensures that the bounding box cannot exceed the matrix
% dimensions. I did get an error once:
%   Subscript indices must either be real positive integers or logicals.
%   Error in sp8_cleandata (line 66)
%       BW2 = BW(yl:yl+dy,xl:xl+dx,zl:zl+dz);
% 
% It must be the way I use ceil and floor. Another possible solution would
% be to use padarray on the 3D matrix, but this works for now and does not
% slow execution much.
%

A(A<1) = 1;

if (A(1) + A(4)) > matSize(2)
    A(4) = matSize(2) - A(1);
end
if (A(2) + A(5)) > matSize(1)
    A(5) = matSize(1) - A(2);
end
if (A(3) + A(6)) > matSize(3)
    A(6) = matSize(3) - A(3);
end

xl=A(1); yl=A(2); zl=A(3); dx=A(4); dy=A(5); dz=A(6);

end

