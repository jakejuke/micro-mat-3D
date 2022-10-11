function sp8_mat2png(A,GT,varargin)
%SP8_MAT2PNG Makes .png images from a 3D grain matrix
%   Detailed explanation goes here
% 
% 
%   Examples:
%       sp8_mat2png(full3Ds{1},fullGT(1))
%       sp8_mat2png(full3Ds{1},fullGT(1),'path','/home/jules/Desktop/imStack')
%   
%   Optional inputs:
%       'path' - should be a string (default working directory)
%       'prefix' - file name prefix
%       'bwGBs' - marks grain boundaries in '2D' or '3D'
%       'minmaxR' - min/max value for Rodrigues vector components
%                   (for cubic symmetry value is sqrt(2)-1)
%       'BGColor' - set BackGround Color to value other than 'k'
%       'Slice' - set orthoslice to 'XY', 'XZ' or 'YZ'
%   
%   
%   Jules Dake
%   Uni Ulm, Jun 2014
% 


%% Parse input variables
p = inputParser;

defaultPath = '~/Desktop/imStackSP8';
defaultFF = 'png';
defaultPre = 'NaN';
defaultGBblack = 'off'; %'off', '2D' or '3D'
defaultMinMaxR = 0.5;%(sqrt(2)-1);
defaultBGColor = 'k';
defaultSlice = 'XY';
defaultColorMap = NaN;

addRequired(p,'A',@isnumeric);
addRequired(p,'GT',@isstruct);
addParameter(p,'path',defaultPath,@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'FF',defaultFF,@ischar);
addParameter(p,'prefix',defaultPre,@ischar);
addParameter(p,'bwGBs',defaultGBblack,@ischar);
addParameter(p,'minmaxR',defaultMinMaxR,@isnumeric);
addParameter(p,'BGColor',defaultBGColor,@ischar);
addParameter(p,'Slice',defaultSlice,@ischar);
addParameter(p,'ColorMap',defaultColorMap,@isnumeric);

parse(p,A,GT,varargin{:});

pathname = p.Results.path;
ff = p.Results.FF;
prefix = p.Results.prefix;
bwGBs = p.Results.bwGBs;
minmaxR = p.Results.minmaxR;
bg = p.Results.BGColor;
orthoSlice = p.Results.Slice;
colormap = p.Results.ColorMap;


%% Some settings
% Warning because GBs can be black like background color
% I'm turning it off because I think it slows execution
warning('off','images:label2rgb:zerocolorSameAsRegionColor')

if isfield(GT, 'timestep') && strcmpi(prefix,'NaN')
    a = GT.timestep;
else
    a = prefix;
end

if isnan(colormap)
    colormap = GT.orient*.5/minmaxR + 0.5;
end


%% Check if target directory already exists
if exist(pathname,'dir')
    display(['Target directory already exists. '...
        '(Over)writing files in ''' pathname ''''])
    % error(['Target directory already exists. '...
    %     'First remove directory ''' pathname tdirname ''''])
else
    eval(['mkdir ' pathname])
end


%% Check if bwGBs set; if so, erode grain boundaries
if strcmpi(bwGBs,'3D')
   B = sp8_gbextract(A);
   A(B>0) = size(GT.orient,1) + 1;
   colormap(end+1,:) = [0 0 0];
elseif strcmpi(bwGBs,'2D')
    gbl = size(GT.orient,1) + 1;
    colormap(end+1,:) = [0 0 0];
end


%% Set slice
if strcmpi(orthoSlice,'XY')
    display('Saving XY images')
elseif strcmpi(orthoSlice,'XZ')
    display('Saving XZ images')
    A = permute(A,[3 2 1]);
elseif strcmpi(orthoSlice,'YZ')
    display('Saving YZ images')
    A = permute(A,[3 1 2]);
else
    error('Options ''Slice'' not set properly')
end


%% Save png's

% for color images
for I = 1:size(A,3)
    s = A(:,:,I);
    if strcmpi(bwGBs,'2D')
        s2 = sp8_gbextract2D(s);
        s(s2>0) = gbl;
    end
    imslice = label2rgb(s, colormap, bg);
    nbr = num2str(I,'%04d');
    imwrite(imslice,[pathname '/' a '_' nbr '.' ff],ff); close
end

% % for bw png's
% for I = 1:size(A,3)
%     imslice = A(:,:,I);
%     nbr = num2str(I,'%03d');
%     imwrite(imslice,[pathname tdirname '/' a '_' nbr '.png'],'png'); close
% end

% % for color tif's
% for I = 1:size(A,3)
%     imslice = label2rgb(A(:,:,I), colormap, 'k');
%     nbr = num2str(I,'%03d');
%     imwrite(imslice,[pathname tdirname '/' a '_' nbr '.tif'],'Compression','none'); close
% end

% % for bw tif's
% for I = 1:size(A,3)
%     imslice = A(:,:,I);
%     nbr = num2str(I,'%03d');
%     imwrite(imslice,[pathname tdirname '/' a '_' nbr '.tif'],'Compression','none'); close
% end

display('   images saved')


end

