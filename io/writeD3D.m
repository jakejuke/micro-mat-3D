%function writeD3D(fullGT,full3D)
%WRITED3D Write a 3DXRD data set to a Dream3D file
%   Detailed explanation goes here

% Load data for testing
% Can use clearvars to remove any later variables
clear
path2mat = '/Users/jules/Documents/Matlab/micro-mat-3D/data/MOUT_bhAll_relabelled.mat';

% Should load reg3Ds for calculations of exchanged volume
load(path2mat, 'full3Ds', 'reg3Ds', 'fullGTs')

clear path2mat
initVars = who;
initVars{end+1} = 'initVars';
%clearvars('-except',initVars{:})

% meshgrid()
% Should I use this function when exporting data?

%% Set initial variables

t = 2; % time step

f_name = 'BH400_quats.txt';
f_path = '/Users/jules/Documents/Matlab/';
s_header = 'Quaternions for BH400 (321 x 321 x 531)';


%% Convert Rodrigues vectors to quaternions

quats = zeros( length(fullGTs(t).labels),4 );

for k=1:length(fullGTs(t).orient(:,1))
    r = fullGTs(t).orient(k,:);
    quats(k,:) = rod2quat( r );
end

fullGTs(t).quat = quats;
q_array = single( zeros( length(full3Ds{t}(:)), 4 ) );

tic
for ind = 1:length(full3Ds{t}(:))
    g_label = full3Ds{t}(ind);
    if g_label > 0
        q_array(ind,:) = fullGTs(t).quat(g_label,:);
    end
end
loop1_time = toc;
fprintf( 'Loop execution time: %.2f seconds\n', loop1_time )


%% Write to text file

fileID = fopen([f_path, f_name],'w');
fprintf(fileID, s_header);
%fprintf(fileID,'%6.2f %12.8f\n',A);
fclose(fileID);

writematrix( q_array, [f_path, f_name], ...
             'WriteMode', 'append', ...
             'Delimiter', '\t' )

%end

% %% rod2quat conversion test
% clearvars('-except',initVars{:})
% t = 1;
% tol = 1e-15;
% d_max = 0;
% for k=1:length(fullGTs(t).orient(:,1))
%     r = fullGTs(t).orient(k,:);
% 
%     q1 = rod2quat( r );
% 
%     o = rotation.byRodrigues( vector3d(r) );
%     q2 = [o.a, o.b, o.c, o.d];
%     
%     d = sum(abs(q1-q2));
%     if d > tol
%         fprintf('Diff is: %e\n', d)
%     end
%     if d > d_max
%         d_max = d;
%     end
% end
% 
% fprintf('The max diff was: %e\n', d_max)
