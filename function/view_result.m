function fig = view_result(result)
%VIEW_RESULT ���ӻ������б���
%   ����:result:n*5ά��������n��ʾ���Ƶĸ�����ǰ����Ϊ���Ƶ����꣬��
%   4��Ϊʵ����𣬵�5��Ϊ�ж������(0:����㣬1:�ǵ����)
% ptCloud_org = pointCloud(result(:,1:3),'Color',create_color(result(:,4)));
% figure
% pcshow(ptCloud_org,'MarkerSize',15);
% hold on
% title("ԭʼ����")
% ������ȡ
index = result(:,4) == result(:,5); % 1��ʾ��ȷ�жϵĵ�
index_err1 = result(:,4)<result(:,5);% ������һ�����ĵ�(����㱻�ж�Ϊ�ǵ����)
index_err2 = result(:,4)>result(:,5);% �����ڶ������ĵ�(�ǵ���㱻�ж�Ϊ�����)

cloud1 = result(index,:); % ��ȷ����ĵ���
cloud2 = result(index_err1,:); % ������һ�����ĵ�
cloud3 = result(index_err2,:); % �����ڶ������ĵ�

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

