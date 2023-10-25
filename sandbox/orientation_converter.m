% Start MTEX and then run...

clear
load('/Users/jules/Documents/Matlab/micro-mat-3D/data/MOUT_bhAll_relabelled.mat', ...
     'fullGTs', 'full3Ds')

%% Time step
ts = 1;
fullGT = fullGTs(ts);
full3D = full3Ds{ts};

clearvars -except fullGT full3D

%% Add a entry with Euler angles to the grain table

m = 1;
fullGT.Euler = zeros(length(fullGT.labels),3);

for p=1:length(fullGT.labels)
    
    r = fullGT.orient(p,:);
    o = rotation.byRodrigues( vector3d(r) );
    o_in_Euler = [o.phi1, o.Phi, o.phi2]*(180/pi);
    fullGT.Euler(p,:) = o_in_Euler;
end
clearvars -except fullGT full3D

%%
ang_mat = single(zeros(length(full3D(:)), 8));

sz = size(full3D);
my_Euler_list = fullGT.Euler;

parfor i=1:length(full3D(:))
    [x, y, z] = ind2sub(sz, i);
    g_label = single(full3D(i));
    if g_label > 0
        g_Euler = my_Euler_list(g_label,:);
        ang_mat(i,:) = [g_Euler, x, y, z, g_label, 1];
    else
        ang_mat(i,:) = [0, 0, 0, x, y, z, g_label, 0];
    end
end

%%

% r = fullGTs(1).orient(1,:);
% o = rotation.byRodrigues( vector3d(r) );
% 
% o_in_Euler = [o.phi1, o.Phi, o.phi2]*(180/pi)

