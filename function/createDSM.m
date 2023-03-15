function [DSM,R,isEmptyCell xi yi] = createDSM(x,y,z,varargin)

% Define inputs

cellSize = [];
inpaintMethod = [];
xi = [];
yi = [];
cType = [];

% Define outputs

DSM = [];
R = [];
isEmptyCell = [];

%% Process supplied arguments

i = 1;
while i<=length(varargin)    
    if isstr(varargin{i})
        switchstr = lower(varargin{i});
        switch switchstr
            case 'c'
                cellSize = varargin{i+1};
                i = i + 2;
            case 'inpaintmethod'
                inpaintMethod = varargin{i+1};
                i = i + 2;
            case 'xi'
                xi = varargin{i+1};
                i = i + 2;
            case 'yi'
                yi = varargin{i+1};
                i = i + 2;
            case 'type'
                cType = varargin{i+1};
                i = i + 2;
            otherwise
                i = i + 1;
        end
    else
        i = i + 1;
    end
end    


    if isempty(cType)
        cType = 'min';
    end
    if isempty(inpaintMethod)
        inpaintMethod = 4; % Springs as default method
    end

    % define cellsize from xi and yi if they were not defined
    if ~isempty(xi) & ~isempty(yi)
        cellSize = abs(xi(2) - xi(1));
    end
    
    if isempty(cellSize)
        error('Cell size must be declared.');
    end
    
    % Define xi and yi if they were not supplied
    if isempty(xi) & isempty(yi)
        xi = ceil2(min(x),cellSize):cellSize:floor2(max(x),cellSize); % min(x)向上最小的整数(cellSize的倍数):cellSize:max(x)向下最大的整数(cellSize的倍数)
        yi = floor2(max(y),cellSize):-cellSize:ceil2(min(y),cellSize); % max(y)向下最大的整数(cellSize的倍数):-cellSize:min(y)向下最小的整数
    end

    % Define meshgrids and referencing matrix
    [XI YI] = meshgrid(xi,yi);
    R = makerefmat(xi(1),yi(1),xi(2) - xi(1),yi(2) - yi(1));
    
    % Create gridded values 将原始的x,y变为栅格中心的xy
    xs = round3(x,xi); 
    ys = round3(y,yi);

    % Translate (xr,yr) to pixels (r,c)
    [r c] = map2pix(R,xs,ys);
    r = round(r);  % Fix any numerical irregularities
    c = round(c);  % Fix any numerical irregularities
    %  Translate pixels to single vector of indexed values
    idx = sub2ind([length(yi) length(xi)],r,c);
    
    % Consolidate those values according to minimum
    [xcon Z] = consolidator(idx,z,cType); % 取落在同一个网格中，最低点的索引xcon以及z值Z

    % Remove any NaN entries.  How these get there, I'm not sure.
    Z(isnan(xcon)) = [];
    xcon(isnan(xcon)) = [];
    
    % Construct image % 使用线性索引非常方便
    DSM = nan(length(yi),length(xi));
    DSM(xcon) = Z;
    
    isEmptyCell = logical(isnan(DSM));
    
    % Inpaint NaNs
    if (inpaintMethod~=-1 & any(isnan(DSM(:))))
        DSM = inpaint_nans(DSM,inpaintMethod);
    end
    
%     tStop = tStart - tStop;

end




function xr2 = floor2(x,xint)
    xr2 = floor(x/xint)*xint;
end

function xr2 = ceil2(x,xint)
    xr2 = ceil(x/xint)*xint;
end

function xs = round3(x,xi) % Snap vector of x to vector xi
    dx = abs(xi(2) - xi(1));
    minxi = min(xi);
    maxxi = max(xi);

    %% Perform rounding on interval dx
    xs = (dx * round((x - minxi)/dx)) + minxi;

    %% Outside the range of xi is marked NaN
    % Fix edge cases
    xs((xs==minxi-dx) & (x > (minxi - (dx)))) = minxi;
    xs((xs==maxxi+dx) & (x < (maxxi + (dx)))) = maxxi;
    % Make NaNs
    xs(xs < minxi) = NaN;
    xs(xs > maxxi) = NaN;
end