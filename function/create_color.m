function [color] = create_color(category)
%CREATE_COLOR 此函数用于生成创建点云对象所需的color参数
%   输入:category是一个一维逻辑向量：0：代表地面点
% 1：代表非地面点
%   地面点：灰色
%   非地面点：绿色
color = zeros(size(category,1),3);
for i=1:length(category)
   if  category(i) == 1
       color(i,:) = [0,1,0.5];
   else
       color(i,:) = [0.54,0.49,0.41];
   end
end
end

