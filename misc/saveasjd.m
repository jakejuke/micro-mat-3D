function saveasjd(filename,varargin)
%SAVEASJD Save Figure as PDF with width 11.25 cm and height 8.4375 cm
%
%   SAVEASJD('FILENAME')
%   Will save the current Figure (uses gcf) to file called FILENAME.
%   FILENAME does not need the '.pdf' extension -- this is added by the
%   function.
%
%   Options:
%   ----------
%       'PaperSize' [width, height] in cm (def [15.75, 11.8125])
%
%   Does:
%     set(gcf, 'PaperUnits', 'centimeters')
%     set(gcf, 'PaperSize', [width height])
%     set(gcf, 'PaperPositionMode', 'manual')
%     set(gcf, 'PaperPosition', [0 0 width height])
%     set(gca, 'Position', [left, bottom, width, height])
%     saveas(gcf,strcat(filename,'.pdf'),'pdf')
%
%   Jules Dake
%   Uni Ulm, Dec 2013
%


% rect = [left, bottom, width, height]



%% Parse input variables
p = inputParser;

addRequired(p,'filename',@ischar);

defaultPaperSize = 1.4*[11.25 8.4375]; % old default value
addParameter(p,'PaperSize',defaultPaperSize,@isnumeric);
defaultPosition = [0.15 0.19 0.79 0.72]; % Used for Rubber Paper
addParameter(p,'Position',defaultPosition,@isnumeric);
defaultDefaults = 'off';
addParameter(p,'Defaults',defaultDefaults,@ischar);

parse(p,filename,varargin{:});

paperSize = p.Results.PaperSize;
myPosition = p.Results.Position;
defaults = p.Results.Defaults;


%% Save
% a = 1.4;
set(gcf, 'PaperUnits', 'centimeters')

switch lower(defaults)
    case 'rubber'
        % defaults for rubber manuscript
        paperSize = [8, 6];
        myPosition = [0.15 0.19 0.79 0.72];
    case 'thesis1'
        paperSize = 10;
        % for thesis: [0.18 0.18 0.78 0.76], fits well with 7.4 cm width and 10
        % new for thesis: [0.15 0.18 0.80 0.76]
        myPosition = [0.15 0.18 0.80 0.76];
    case 'thesis2'
        paperSize = 7; % 7.4 is the full space, but too tight if used
        myPosition = [0.16 0.18 0.80 0.76];
    case 'thesis3'
        paperSize = 4.9; % 7.4 is the full space, but too tight if used
        myPosition = [0.16 0.18 0.80 0.76];
    otherwise
        disp('''Defaults'' can be: rubber, thesis1 or thesis2')
end

% set(gca, 'Position', [0.16 0.14 0.78 0.80]) <- Used for a LONG time!
% set(gca, 'Position', [0.12 0.12 0.80 0.80])
if length(paperSize) == 1
    paperSize = [paperSize, 3*paperSize/4];
end
set(gcf, 'PaperSize', paperSize)
set(gcf, 'PaperPositionMode', 'manual') % is the default
set(gcf, 'PaperPosition', [0 0 paperSize(1) paperSize(2)])
set(gcf, 'PaperSize', paperSize)
set(gca, 'Position', myPosition)

%%%

saveas(gcf,strcat(filename,'.pdf'),'pdf')

end