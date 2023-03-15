function ptCloud = OutTrend(ptCloud)
%OutTrend 点云去趋势
%   输入pointCloud对象，输出去趋势后的pointCloud对象
    % OutTrend函数，输入pointCloud对象，返回去掉趋势以后的pointCloud对象
    x = ptCloud.Location(:,1);
    y = ptCloud.Location(:,2);
    z = ptCloud.Location(:,3);
    cellSize = 30;
    inpaintMethod = 4;
    [ZImin R isEmptyCell xi yi] = createDSM(x,y,z,'c',cellSize,'type','min','inpaintMethod',inpaintMethod); 
    % 构成网格
    [XI,YI] = meshgrid(xi,yi);
    % 径向基插值
    op=rbfcreate([XI(:)'; YI(:)'], ZImin(:)','RBFFunction', 'gaussian'); rbfcheck(op);
    
    Z_surface = rbfinterp([x';y'],op);
    % 先假设Z_trend_out里面不会出现负数
    Z_trend_out = z - (Z_surface'-10);
    
    % 去趋势后的点云
    ptCloud = pointCloud([x,y,Z_trend_out],'Color',ptCloud.Color);
end

