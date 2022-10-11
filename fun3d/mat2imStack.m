function mat2imStack(A,varargin)
%MAT2IMSTACK Convert a 3D matrix to a series of images
%   
%   MAT2IMSTACK(A,...) saves each layer of the 3D matrix A as an image
%   slice using the function imwrite.
%
%   Options
%   ----------
%       'FF' - fileformat, accepts as input 'png' or 'tif'
%              (default: 'png')
%       'PathName' - path to target directory without final '/'
%                    (default: working directory)
%       'TargetDir' - name of target directory
%                     (default: 'mat2imStack')
%       'Prefix' - prefix of file name; an underscore and running 4 digit
%                  number will be automatically added to each image
%                  (default: 'a')
%       'Slice' - which way the stack should be sliced: 'XY', 'XZ' or 'YZ'
%                 (default: 'XY')
%   
%   Example
%   ----------
%       mat2imStack(A,'FF','tif','PathName','~/Desktop','Prefix','rb60','TargetDir','regCT')
%   
%   Jules Dake
%   Uni Ulm, 28 Oct 2014
%   


%% Parse input variables
p = inputParser;

defaultFF = 'png';
defaultPath = pwd;
defaultTDir = 'mat2imStack';
defaultPre = 'a';
defaultSlice = 'XY';
% defaultBGColor = 'w';

addRequired(p,'A',@isnumeric);
addParameter(p,'FF',defaultFF,@ischar);
addParameter(p,'PathName',defaultPath,@(x)validateattributes(x,{'char'},{'nonempty'}));
addParameter(p,'TargetDir',defaultTDir,@ischar);
addParameter(p,'Prefix',defaultPre,@ischar);
addParameter(p,'Slice',defaultSlice,@ischar);
%addParameter(p,'BGColor',defaultBGColor,@ischar);

parse(p,A,varargin{:});
ff = p.Results.FF;
pathname = [p.Results.PathName '/'];
tdirname = p.Results.TargetDir;
prefix = p.Results.Prefix;
orthoSlice = p.Results.Slice;
%bg = p.Results.BGColor;


%% Check if target directory already exists
wd = pwd; cd(pathname)

if exist(tdirname,'dir')
    display(['Target directory already exists. '...
        '(Over)writing files in ''' pathname tdirname ''''])
    % error(['Target directory already exists. '...
    %     'First remove directory ''' pathname tdirname ''''])
else
    eval(['mkdir ' tdirname])
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


%% Save slices
if strcmpi(ff,'png')
    % for bw png's
    for I = 1:size(A,3)
        imslice = A(:,:,I);
        nbr = num2str(I,'%04d');
        imwrite(imslice,[pathname tdirname '/' prefix '_' nbr '.png'],'png'); close
    end
elseif strcmpi(ff,'tif')
    % for bw tif's
    for I = 1:size(A,3)
        imslice = A(:,:,I);
        nbr = num2str(I,'%04d');
        imwrite(imslice,...
            [pathname tdirname '/' prefix '_' nbr '.tif'],'Compression','none'); close
    end
else
    error('Only ''tif'' and ''png'' fileformats supported')
end

cd(wd)

end

