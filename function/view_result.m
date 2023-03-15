function fig = view_result(result)
%VIEW_RESULT 可视化点云判别结果
%   输入:result:n*5维的向量，n表示点云的个数，前三列为点云的坐标，第
%   4列为实际类别，第5列为判定的类别(0:地面点，1:非地面点)
% ptCloud_org = pointCloud(result(:,1:3),'Color',create_color(result(:,4)));
% figure
% pcshow(ptCloud_org,'MarkerSize',15);
% hold on
% title("原始点云")
% 误判提取
index = result(:,4) == result(:,5); % 1表示正确判断的点
index_err1 = result(:,4)<result(:,5);% 产生第一类误差的点(地面点被判定为非地面点)
index_err2 = result(:,4)>result(:,5);% 产生第二类误差的点(非地面点被判定为地面点)

cloud1 = result(index,:); % 正确分类的点云
cloud2 = result(index_err1,:); % 产生第一类误差的点
cloud3 = result(index_err2,:); % 产生第二类误差的点

color1 = create_color(cloud1(:,4));
color2 = [ones(size(cloud2,1),1),ones(size(cloud2,1),1),zeros(size(cloud2,1),1)];
color3 = [ones(size(cloud3,1),1),zeros(size(cloud3,1),1),zeros(size(cloud3,1),1)];

cloud = [cloud1;cloud2;cloud3];
color = [color1;color2;color3];

ptCloud_res = pointCloud(cloud(:,1:3),'Color',color);
figure
fig = pcshow(ptCloud_res,'MarkerSize',15);
% axis off
end

