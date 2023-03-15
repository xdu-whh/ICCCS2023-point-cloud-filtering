function [ZIfin R isObject ZIpro ZImin isObjectCell] = smrf(x,y,z,varargin)

if nargin < 9
    error('Minimum call: smrf(x,y,z,''c'',c,''s'',s,''w'',w)');
end

dependencyCheck = [exist('consolidator') exist('inpaint_nans')];
if any(dependencyCheck==0)
    disp('The smrf algorithm requires that consolidator.m and inpaint_nans.m are accessible.');
    disp('Both of these functions were written by John D''Errico and are available through the');
    disp('Mathworks file exchange.');
    disp('consolidator is located at http://www.mathworks.com/matlabcentral/fileexchange/8354');
    disp('inpaint_nans is located at http://mathworks.com/matlabcentral/fileexchange/4551');
    error('Please acquire these files before attempting to run smrf again.');
end
% Initialize possible input values
cellSize = [];
slopeThreshold = [];
wkmax = [];
xi = [];
yi = [];
elevationThreshold = [];
elevationScaler = [];

% Initialize output values
ZIfin = [];
R = [];
isObject = [];

% Declare other global variables
inpaintMethod = 4;  % Springs
cutNetSize = [];
isNetCell = [];


%% Process extra arguments

i = 1;
while i<=length(varargin)    
    if isstr(varargin{i})
        switchstr = lower(varargin{i});
        switch switchstr
            case 'c' % Cell size (required, or xi and yi must be supplied)
                cellSize = varargin{i+1};
                i = i + 2;
            case 's' % Slope tolerance (required)
                slopeThreshold = varargin{i+1};
                i = i + 2;
            case 'w' % Maximum window size, in map units (required)
                wkmax = varargin{i+1};
                i = i + 2;  
            case 'et'   % Elevation Threshold (optional)
                elevationThreshold = varargin{i+1};
                i = i + 2;
            case 'es'   % Elevation Scaling Factor (optional)
                elevationScaler = varargin{i+1};
                i = i + 2;
            case 'xi'   % A supplied vector for x
                xi = varargin{i+1};
                i = i + 2;
            case 'yi'   % A supplied vector for y
                yi = varargin{i+1};
                i = i + 2;        
            case 'inpaintmethod'  % Argument to pass to inpaint_nans.m
                inpaintMethod = varargin{i+1};
                i = i + 2;
            case 'cutnet'   % Support to a cut a grid into large datasets
                cutNetSize = varargin{i+1};
                i = i + 2;
            case 'objectMask'
                objectMask = varargin{i+1};
                i = i + 2;
            otherwise
                i = i + 1;
        end
    else
        i = i + 1;
    end
end    


%% Check for a few error conditions

if isempty(slopeThreshold)
    error('Slope threshold must be supplied.');
end

if isempty(wkmax)
    error('Maximum window size must be supplied.');
end

if isempty(cellSize) && isempty(xi) && isempty(yi)
    error('Cell size or (xi AND yi) must be supplied.');
end

if isempty(xi) && ~isempty(yi)
    error('If yi is defined, xi must also be defined.');
end

if ~isempty(xi) && isempty(yi)
    error('If xi is defined, yi must also be defined.');
end

if ~isempty(xi) && ~isvector(xi)
    error('xi must be a vector');
end

if ~isempty(yi) && ~isvector(yi)
    error('yi must be a vector');
end

if ~isempty(xi) && (abs(xi(2) - xi(1)) ~= abs(yi(2) - yi(1)))
    error('xi and yi must be incremented identically');
end

if isempty(cellSize) && ~isempty(xi) && ~isempty(yi)
    cellSize = abs(xi(2) - xi(1));
end

if ~isempty(elevationThreshold) && isempty(elevationScaler)
    elevationScaler = 0;
end

%% Create Digital Surface Model
if isempty(xi)
    [ZImin R isEmptyCell xi yi] = createDSM(x,y,z,'c',cellSize,'type','min','inpaintMethod',inpaintMethod);
else
    [ZImin R isEmptyCell] = createDSM(x,y,z,'xi',xi,'yi',yi,'type','min','inpaintMethod',inpaintMethod);
end

%% Detect outliers

[isLowOutlierCell] = progressiveFilter(-ZImin,'c',cellSize,'s',5,'w',1); 

%% Cut a mesh into Zmin, if desired
if ~isempty(cutNetSize)
    [ZInet isNetCell] = createNet(ZImin,cellSize,cutNetSize);
else
    ZInet = ZImin;
    isNetCell = logical(zeros(size(ZImin)));
end

%% Detect objects

[isObjectCell] = progressiveFilter(ZInet,'c',cellSize,'s',slopeThreshold,'w',wkmax); 

%% Construct a prospective ground surface

ZIpro = ZImin;
ZIpro(isEmptyCell | isLowOutlierCell | isObjectCell | isNetCell) = NaN;
ZIpro = inpaint_nans(ZIpro,inpaintMethod);
isObjectCell = isEmptyCell | isLowOutlierCell | isObjectCell | isNetCell;


%% Identify ground ...
% based on elevationThreshold and elevationScaler, if provided

if ~isempty(elevationThreshold) && ~isempty(elevationScaler)

    % Identify Objects
        % Calculate slope
    [gx gy] = gradient(ZIpro/cellSize);
    gsurfs = sqrt(gx.^2 + gy.^2); % Slope of final estimated ground surface
    clear gx gy
            
    % Get Zpro height and slope at each x,y point
    iType = 'spline';
    [r c] = map2pix(R,x,y);
    ez = interp2(ZIpro,c,r,iType);
    SI = interp2(gsurfs,c,r,iType);
    clear r c

    requiredValue = elevationThreshold + (elevationScaler * log(1+SI));
    isObject = abs(ez-z) > requiredValue;
    clear ez SI requiredValue 
    
    
    % Interpolate final ZI
   F = TriScatteredInterp(x(~isObject),y(~isObject),z(~isObject),'natural');
   [XI,YI] = meshgrid(xi,yi);
   ZIfin = F(XI,YI);
else
   warning('Since elevation threshold and elevation scaling factor were not provided for ground identification, ZIfin is equal to ZIpro.');
   ZIfin = ZIpro;
end



end  % Function end