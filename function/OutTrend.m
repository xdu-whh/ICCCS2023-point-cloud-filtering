function ptCloud = OutTrend(ptCloud)
%OutTrend ����ȥ����
%   ����pointCloud�������ȥ���ƺ��pointCloud����
    % OutTrend����������pointCloud���󣬷���ȥ�������Ժ��pointCloud����
    x = ptCloud.Location(:,1);
    y = ptCloud.Location(:,2);
    z = ptCloud.Location(:,3);
    cellSize = 30;
    inpaintMethod = 4;
    [ZImin R isEmptyCell xi yi] = createDSM(x,y,z,'c',cellSize,'type','min','inpaintMethod',inpaintMethod); 
    % ��������
    [XI,YI] = meshgrid(xi,yi);
    % �������ֵ
    op=rbfcreate([XI(:)'; YI(:)'], ZImin(:)','RBFFunction', 'gaussian'); rbfcheck(op);
    
    Z_surface = rbfinterp([x';y'],op);
    % �ȼ���Z_trend_out���治����ָ���
    Z_trend_out = z - (Z_surface'-10);
    
    % ȥ���ƺ�ĵ���
    ptCloud = pointCloud([x,y,Z_trend_out],'Color',ptCloud.Color);
end

