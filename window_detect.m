function w = window_detect(img)
%WINDOW_DETECT 滤波窗口大小自动检测
%   输入点云生成的灰度图像
%   输出最大的滤波窗口半径(单位：像素)
T = adaptthresh(img, 0.5);
B = imbinarize(img,T);
% figure
% imshowpair(img,B,'montage')
se = strel('disk',3);
img_open = imopen(B,se);
% figure
% imshow(img_open)

out_result=regionprops(img_open,'Extent','Centroid','boundingbox');
centroids = cat(1, out_result.Centroid);   % 各连通区域质心
draw_rect=cat(1,out_result.BoundingBox);   % 各连通区域最小边界矩形
% figure
% imshow(B)
% hold on
% for i=1:size(out_result)
%     rectangle('position',draw_rect(i,:),'EdgeColor','y','linewidth',2) 
% end
% draw_rect的第3、4列中的最大值，
% 即为所有矩形的最大边长，应该使用这个值作为滤波窗口的大小(单位：像素)
% 除以二得到窗口半径大小
w = ceil(max(max(draw_rect(:,3:4)))/2);
end

