function [ZInet isNetCell] = createNet(ZImin,cellSize,gridSize)

    bigOpen = imopen(ZImin,strel('disk',2*ceil(gridSize/cellSize)));
    isNetCell = logical(zeros(size(ZImin)));
    isNetCell(:,1:ceil(gridSize/cellSize):end) = 1;
    isNetCell(1:ceil(gridSize/cellSize):end,:) = 1;
    
    ZInet = ZImin;
    ZInet(isNetCell) = bigOpen(isNetCell);
    