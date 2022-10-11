function [fullGTs, trackmat, ovlpMat] = sp8_quicktrack(full3Ds, fullGTs, varargin)
%SP8_QUICKTRACK Quick grain tracking 
%   sp8_quicktrack(full3Ds, fullGTs) tracks grains across multiple time
%   steps in a two step process. First a rough guess is made with an
%   initial set up parameters (e.g. 75% overlap and maximum misorientation
%   of 5 degrees). Then the mean misorientation is applied to all grains
%   and a second guess is made with different cut-off values (e.g. 25%
%   overlap but only 0.5 degree misorientation).
%
%   This function works best for registered data sets.
%   
%   EXAMPLE:
%       [fullGTs, trackmat, ovlpMat] = sp8_quicktrack(full3Ds, fullGTs);
%   
%   OPTIONS:
%       'ovlpMat' -- can be supplied to function to save time
%       'ovlpCuts' -- defaults are [.75 0.25]
%       'misoCuts' -- defaults are [5 0.5]
%
%   
%   Jules Dake, 2014
%   Uni Ulm
%   

%%  To do:
%   - Check if two grains from timestep2 are assigned to the same grain
%     from timestep1.
%   - Refine orientations of all subsequent timesteps relative to initial
%     timestep 
%   - 

%% Bugs:
%   - there is no overlap with zero (index problem in matlab) -> I should
%   divide by volume and not like: ovlpFrac = ovlpGnum(end)/sum(ovlpGnum)


%% Parse input variables
p = inputParser;

defaultOvlpMat = 0;
defaultOvlpCuts = [.75 0.25];
defaultMisoCuts = [5 0.5];

addRequired(p,'full3Ds',@iscell);
addRequired(p,'fullGTs',@isstruct);
addParameter(p,'ovlpMat',defaultOvlpMat,@iscell);
addParameter(p,'ovlpCuts',defaultOvlpCuts,@isnumeric);
addParameter(p,'misoCuts',defaultMisoCuts,@isnumeric);

parse(p,full3Ds,fullGTs,varargin{:});

ovlpMat = p.Results.ovlpMat;
ovlpCut1 = p.Results.ovlpCuts(1); ovlpCut2 = p.Results.ovlpCuts(2);
misorCut1 = p.Results.misoCuts(1); misorCut2 = p.Results.misoCuts(2);

% Add new fields to grain tables
fullGTs = initfullgts(fullGTs);
if iscell(ovlpMat)
    fprintf('\nUsing ovlpMat from user input\n')
else
    fprintf('\nGenerating new ovlpMat\n')
    ovlpMat = initovlpmat(full3Ds);
    save('ovlpMat_new.mat','ovlpMat')
end
fprintf('Using ovlpCuts: %.2f %.2f\n',ovlpCut1,ovlpCut2)
fprintf('Using misoCuts: %.2f %.2f\n',misorCut1,misorCut2)


%% Main code
for J=2:length(full3Ds)

gT1 = fullGTs(J-1);
gT2 = fullGTs(J);

display(' ')
display(['Quick track: ' num2str(J-1) ' of ' num2str(length(full3Ds)-1)])
display(['  tracking ' fullGTs(J-1).timestep ' and ' fullGTs(J).timestep])

% save values from first iteration
newlabels1 = nan(size(gT2.labels));
trackinfo1 = nan(length(gT2.labels),7);

% loop1: loop through all grains of the second timestep (hence gnum2)
for I = 1:length(gT2.labels)
    %
    gnum2 = gT2.labels(I);
    ovlpGnum = sort(ovlpMat{J}((ovlpMat{J}(:,gnum2) > 0),gnum2));
    
    if ~isempty(ovlpGnum)
        ovlpFrac = ovlpGnum(end)/sum(ovlpGnum);
        gnum1 = find(ovlpMat{J}(:,gnum2)==ovlpGnum(end));
        % if there are two grains with equal overlap, take the first
        gnum1 = gnum1(1);
        
        gOrient1 = gT1.orient(gT1.labels==gnum1,:);
        gOrient2 = gT2.orient(gT2.labels==gnum2,:);
        % want to go from timestep2 to timestep1
        [misor12, ~, ~, r12] = calcmisor(gOrient2,gOrient1);
        
        % if I leave off '&& misor12 <= misorCut1' the std gets much larger
        % there are a few grains with large overlap and a large misorientation
        if ovlpFrac >= ovlpCut1 && misor12 <= misorCut1
            % match
            % save one, misor12 & ovlpFrac
            newlabels1(gT2.labels==gnum2) = gnum1;
            trackinfo1(I,:) = [gnum1 gnum2 ovlpFrac misor12 r12];
        else
            % not a match
        end
    end
end
% figure; hist(trackinfo1(isfinite(trackinfo1(:,4)),4),40)

% display initial tracking stats
display(['Initially tracked ' num2str(nnz(isfinite(newlabels1)))...
    ' of ' num2str(length(gT2.labels)) ' grains'])
display(['That is ' num2str(nnz(isfinite(newlabels1))/length(gT2.labels)*100)...
    '% of grains'])
display(['Average misorientation of tracked grains is: ' ...
    num2str(nanmean(trackinfo1(:,4))) ' degrees'])
display(['Standard deviation is: ' ...
    num2str(nanstd(trackinfo1(isfinite(trackinfo1(:,4)),4)))])

% update the grain orientations of timestep2 to match those of timestep1
r_mean = [nanmean(trackinfo1(:,5)), nanmean(trackinfo1(:,6)), ...
    nanmean(trackinfo1(:,7))];
U_mean = r2U(r_mean); gT2.tkUmean = U_mean;
for I = 1:length(gT2.labels)
    % The orientation matrices (U's) are orthagonal, i.e. the transpose is
    % equal to the inverse!
    % take orientation of timestep2 back to timestep1
    gT2.tkregorient(I,:) = U2r(r2U(gT2.orient(I,:))*U_mean);
end

% loop2: loop through all grains of the second timestep again
for I = 1:length(gT2.labels)
    %
    gnum2 = gT2.labels(I);
    gOrient2 = gT2.tkregorient(gT2.labels==gnum2,:);
    
    ovlpGnum = sort(ovlpMat{J}((ovlpMat{J}(:,gnum2) > 0),gnum2),'descend');
    
    if ~isempty(ovlpGnum)
        % sorted above in descending order
        for K = 1:length(ovlpGnum)
            ovlpFrac = ovlpGnum(K)/sum(ovlpGnum);
            gnum1 = find(ovlpMat{J}(:,gnum2)==ovlpGnum(K));
            % if there are two grains with equal overlap, take the first
            gnum1 = gnum1(1);
            gOrient1 = gT1.orient(gT1.labels==gnum1,:);
            misor12 = calcmisor(gOrient2,gOrient1);
            
            if ovlpFrac >= ovlpCut2 && misor12 <= misorCut2
                % it's a match
                gT2.tklabels(gT2.labels==gnum2) = gnum1;
                gT2.tkovlp(gT2.labels==gnum2,:) = ovlpFrac;
                gT2.tkmisor(gT2.labels==gnum2,:) = misor12;
                break
            elseif K==length(ovlpGnum)
                % it's not a match; save best guess
                % label1, label2, gradius1, gradius2, misor12, ovlp
                gnum1 = find(ovlpMat{J}(:,gnum2)==ovlpGnum(1));
                gnum1 = gnum1(1); % if two grains with same ovlp
                gOrient1 = gT1.orient(gT1.labels==gnum1,:);
                misor12 = calcmisor(gOrient2,gOrient1);
                ovlpFrac = ovlpGnum(1)/sum(ovlpGnum);
                gT2.tkbestg(gT2.labels==gnum2,:) = ...
                    [gnum1 gnum2 gT1.gradius(gT1.labels==gnum1) ...
                    gT2.gradius(gT2.labels==gnum2) misor12 ovlpFrac];
            end
        end
    else
        % not tracked; no overlap; no best guess; maybe new grain?
    end
end

% display final tracking stats
display(['Finally tracked ' num2str(nnz(isfinite(gT2.tklabels)))...
    ' of ' num2str(length(gT2.labels)) ' grains'])
display(['That is ' num2str(nnz(isfinite(gT2.tklabels))/length(gT2.labels)*100)...
    '% of grains'])

fullGTs(J) = gT2;
clear gT1 gT2 newlabels1 trackinfo1

end

trackmat = maketrackmat(fullGTs);

end


%-------------------------------------------------------------------------%
%                        Local subfunctions                               %
%-------------------------------------------------------------------------%
function fullGTs = initfullgts(fullGTs)
% new fields being added to grain tables:
%   - tklabels      tracked labels
%   - tkovlp        overlap with tracked grain
%   - tkmisor       misori. with tracked grain
%   - tkUmean       mean misori. of all initially tracked grains
%   - tkregorient   registered orienation of tracked grains
%   - tkbestg       best guess for tracking

fullGTs(1).tklabels = fullGTs(1).labels;
fullGTs(1).tkovlp = ones(length(fullGTs(1).labels),1);
fullGTs(1).tkmisor = zeros(length(fullGTs(1).labels),1);
fullGTs(1).tkUmean = [1 0 0; 0 1 0; 0 0 1];
fullGTs(1).tkregorient = fullGTs(1).orient;
fullGTs(1).tkbestg = nan(length(fullGTs(1).labels),6);

for I=2:length(fullGTs)
    fullGTs(I).tklabels = nan(length(fullGTs(I).labels),1);
    fullGTs(I).tkovlp = nan(length(fullGTs(I).labels),1);
    fullGTs(I).tkmisor = nan(length(fullGTs(I).labels),1);
    fullGTs(I).tkUmean = nan(3);
    fullGTs(I).tkregorient = nan(length(fullGTs(I).labels),3);
    fullGTs(I).tkbestg = nan(length(fullGTs(I).labels),6);
end
end


function ovlpMat = initovlpmat(full3Ds)

for I=2:length(full3Ds)
    display('Calculating ovlpMat, can take about 5 min.')
    tic
    ovlpMat{I} = sp8_calcoverlap(full3Ds{I-1}(:),full3Ds{I}(:));
    toc
end
end


function trackmat = maketrackmat(fullGTs)

trackmat = nan(length(fullGTs(1).labels),length(fullGTs));
trackmat(:,1) = fullGTs(1).labels;
for I=2:length(fullGTs)
    %
    for J=1:length(fullGTs(I).tklabels)
        
        trackmat(trackmat(:,I-1)==fullGTs(I).tklabels(J),I) = ...
            fullGTs(I).labels(J);
    end
end
end


