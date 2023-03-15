function [isObjectCell lastSurface thisSurface] = progressiveFilter(lastSurface,varargin)
% 参数
cellSize = [];
slopeThreshold = [];
wkmax = [];


inpaintMethod = [];
strelShape = [];


isObjectCell = [];


%% 处理输入参数

i = 1;
while i<=length(varargin)    
    if isstr(varargin{i})
        switchstr = lower(varargin{i});
        switch switchstr
            case 'c'
                cellSize = varargin{i+1};
                i = i + 2;
            case 's'
                slopeThreshold = varargin{i+1};
                i = i + 2;
            case 'w'
                wkmax = varargin{i+1};
                i = i + 2;  
            case 'inpaintmethod'
                inpaintMethod = varargin{i+1};
                i = i + 2;
            case 'shape'
                strelShape = varargin{i+1};
                i = i + 2;
            otherwise
                i = i + 1;
        end
    else
        i = i + 1;
    end
end


%% 捕获错误

if isempty(cellSize)
    error('Cell size must be specified.');
end
if isempty(wkmax)
    error('Maximum window size must be specified');
end
if isempty(slopeThreshold)
    error('Slope threshold value must be specified.');
end


%% 定义默认参数

if isempty(inpaintMethod)
    inpaintMethod = 4; % Springs
end

if isempty(strelShape)
    strelShape = 'disk';
end


%% 窗口尺寸计算  


if numel(wkmax)~=1
    wk = ceil(wkmax / cellSize);
else
    wk = 1 : ceil(wkmax / cellSize);
end

% wk = wkmax;
%% 高程阈值计算

eThresh = slopeThreshold * (wk * cellSize);


%% 形态学滤波

isObjectCell = logical(zeros(size(lastSurface)));

for i = 1:length(wk)
    thisSurface = imopen(lastSurface,strel(strelShape,wk(i)));
    isObjectCell = isObjectCell | (lastSurface - thisSurface > eThresh(i));
    lastSurface = thisSurface;
end

