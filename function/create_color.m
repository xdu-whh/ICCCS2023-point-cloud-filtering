function [color] = create_color(category)
%CREATE_COLOR �˺����������ɴ������ƶ��������color����
%   ����:category��һ��һά�߼�������0����������
% 1������ǵ����
%   ����㣺��ɫ
%   �ǵ���㣺��ɫ
color = zeros(size(category,1),3);
for i=1:length(category)
   if  category(i) == 1
       color(i,:) = [0,1,0.5];
   else
       color(i,:) = [0.54,0.49,0.41];
   end
end
end

