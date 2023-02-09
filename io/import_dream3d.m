%% Import data from Dream.3D through import wizzard

T = synthGencube300d20out1;
grainIDs = T.FeatureIds;

% Initilize parameters
cellSize = 300;
gMat = uint16(zeros(cellSize,cellSize,cellSize));


%% Write grain id's to 3D matrix
c = 0;
for z=1:300
    for y=1:300
        for x=1:300
            c = c + 1;
            gMat(x,y,z) = grainIDs(c);
        end
    end
end

%%
eulerAngles = [T.EulerAngles_0, T.EulerAngles_1, T.EulerAngles_2];
uniqueGrainIDs = unique(grainIDs);

rotmat = zeros(length(uniqueGrainIDs),10);

for m = 1:length(uniqueGrainIDs)
    goi = uniqueGrainIDs(m);
    A = grainIDs==goi;
    eulerTemp = unique(eulerAngles(A,:));
    if length(eulerTemp) > 3
        error('Multiple orientations for Grain ID: %d', goi)
    else
        rot = rotation.byEuler(eulerTemp(1),eulerTemp(2),eulerTemp(3));
        U = rot.matrix;
        rotmat(m,:) = [goi, U(1,:), U(2,:), U(3,:)];
    end
end


%% 
%load('/Users/jules/DREAM3DData/Synthetic_Gens/synthGen_cube300_d20_out1.mat')
clearvars('-except',"rotmat","gMat")

% %% Make fullGT for sp8 functions
% ifields = {'timestep',{},'old',{},'labels',{},'orient',{}};
% fullGT = struct(ifields{:});
% 
% fullGT(1).timestep = 'synthGen Dream3D';
% fullGT.labels = unique(gMat);
% fullGT.orient = zeros(length(fullGT.labels),3);
% for p=1:length(fullGT.labels)
%      b = U2r([rotmat(p,2:4); rotmat(p,5:7); rotmat(p,8:10);]);
%      [~, ~, ~, fullGT.orient(p,:), ~] = mymisorientation([0 0 0], b);
% end
% fullGT.old = fullGT.orient;

% select one 2D slice from the 3D volume
slice = 1;
map2d = gMat(:,:,slice);
% create reduced list of grain orientations just for this slice
gIDs_slice = unique(map2d);
gOri_slice = single(rotmat(ismember(rotmat(:,1),gIDs_slice),:));
% relabel grians from 1 to number of grains in the slice
for p=1:length(gIDs_slice)
    map2d( map2d == gIDs_slice(p) ) = p;
    gOri_slice(p,1) = p;
end

%% Write files for 2D PF simulation
cellSize = 300;

[X, Y] = meshgrid(1:cellSize,1:cellSize);
maxPhase = 1;

ops_Export = zeros(cellSize^2,4);

c = 0;
for p = 1:cellSize
    for q = 1:cellSize
        c = c + 1; % or: (p-1)*cellSize + q, but maybe this is faster?
        ops_Export(c,:) = [X(p,q), Y(p,q), maxPhase, map2d(p,q)];
    end
end

writematrix(ops_Export,'synthGen_cube300_d20_out1_slice1_ops.txt','Delimiter','space')
writematrix(gOri_slice(:,2:end),'synthGen_cube300_d20_out1_slice1_orimap.txt','Delimiter','space')

%% Read in sim data
simList = simStep18000;
simMat = uint16(zeros(cellSize,cellSize));

for r=1:length(simList)
    simMat(simList(r,1),simList(r,2)) = simList(r,3);
end


%% Load slices from simulation

load('/Users/jules/DREAM3DData/Synthetic_Gens/temp_simImport.mat')


%% Calculate the misorientations for only the grains in the two slices

s1 = simMat18000;
s2 = simMat20000;

gIDs = unique(s1);

misorMat = nan(max(gIDs),max(gIDs));

for p=1:length(gIDs)
    grainA = gIDs(p);
    U1 = rotmat( rotmat(:,1)==grainA, 2:end );
    UA = [ U1(1:3);
           U1(4:6);
           U1(7:9) ];
    for q=1:length(gIDs)
        grainB = gIDs(q);
        U2 = rotmat( rotmat(:,1)==grainB, 2:end );
        UB = [ U2(1:3);
               U2(4:6);
               U2(7:9) ];
        misorAngle = mymisorientation(UA,UB);
        misorMat(grainA,grainB) = misorAngle;
    end
end


%% Create "difference slice" with misorientation of exchanged volume

D = abs(single(s2) - single(s1)) > 0;
Indx = find(D);

misorMap = zeros(size(s1));

for p=1:length(Indx)
    grainA = s1(Indx(p));
    grainB = s2(Indx(p));
    misorMap(Indx(p)) = misorMat(grainA,grainB);
end

figure
image(s1)
axis off
axis equal

figure
image(s2)
axis off
axis equal

figure
imagesc(misorMap)
axis off
h = colorbar;
h.Limits = [0 67.2]



