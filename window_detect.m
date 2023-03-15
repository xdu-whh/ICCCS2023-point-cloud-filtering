function w = window_detect(img)
%WINDOW_DETECT �˲����ڴ�С�Զ����
%   ����������ɵĻҶ�ͼ��
%   ��������˲����ڰ뾶(��λ������)
T = adaptthresh(img, 0.5);
B = imbinarize(img,T);
% figure
% imshowpair(img,B,'montage')
se = strel('disk',3);
img_open = imopen(B,se);
% figure
% imshow(img_open)

out_result=regionprops(img_open,'Extent','Centroid','boundingbox');
centroids = cat(1, out_result.Centroid);   % ����ͨ��������
draw_rect=cat(1,out_result.BoundingBox);   % ����ͨ������С�߽����
% figure
% imshow(B)
% hold on
% for i=1:size(out_result)
%     rectangle('position',draw_rect(i,:),'EdgeColor','y','linewidth',2) 
% end
% draw_rect�ĵ�3��4���е����ֵ��
% ��Ϊ���о��ε����߳���Ӧ��ʹ�����ֵ��Ϊ�˲����ڵĴ�С(��λ������)
% ���Զ��õ����ڰ뾶��С
w = ceil(max(max(draw_rect(:,3:4)))/2);
end

