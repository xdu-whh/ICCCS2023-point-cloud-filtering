function [s,category] = shope(ZImin,cellSize)
%SHOPE 将地面网格数据进行8分类，分类计算坡度。
%   此处显示详细说明

[gy,gx] = gradient(ZImin); % gy是水平方向的中心差分，gx是竖直方向的中心差分。
% 方向的平均值使用向量之和来近似计算
Gx = sum(gx(:));
Gy = sum(gy(:));
r = atan(Gy/Gx); % 坡向(单位:弧度)
% 将r转换为0到2pi的弧度
if Gx>=0 && Gy>=0
    theta = r;
elseif Gx<0 && Gy>=0
    theta = r + pi;
elseif Gx<0 && Gy<0
    theta = r + pi;
elseif Gx>=0 && Gy<0
    theta = r + 2*pi;
end

% 对坡向进行分类，根据r的取值范围将r划归为8个类别。
if theta>=11*pi/6 || theta<pi/6
    category = 'down';
elseif theta>=pi/6 && theta<2*pi/6
    category = 'right_down';
elseif theta>=2*pi/6 && theta<4*pi/6
    category = 'right';
elseif theta>=4*pi/6 && theta<5*pi/6
    category = 'right_up';
elseif theta>=5*pi/6 && theta<7*pi/6
    category = 'up';
elseif theta>=7*pi/6 && theta<8*pi/6
    category = 'left_up';
elseif theta>=8*pi/6 && theta<10*pi/6
    category = 'left';
elseif theta>=10*pi/6 && theta<11*pi/6
    category = 'left_down';
end


left_up_core = [1,0;0,-1];
right_up_core = [0,1;-1,0];
left_down_core = [0,-1;1,0];
right_down_core = [-1,0,0,1];
left_core = [1,-1];
right_core = [-1,1];
up_core = [1,-1]';
down_core = [-1,1];

switch category
    case 'up'
        f = imfilter(ZImin,up_core)/cellSize;
    case 'down'
        f = imfilter(ZImin,down_core)/cellSize;
    case 'left'
        f = imfilter(ZImin,left_core)/cellSize;
    case 'right'
        f = imfilter(ZImin,right_core)/cellSize;
    case 'left_up'
        f = imfilter(ZImin,left_up_core)/(sqrt(2)*cellSize);
    case 'left_down'
        f = imfilter(ZImin,left_down_core)/(sqrt(2)*cellSize);
    case 'right_up'
        f = imfilter(ZImin,right_up_core)/(sqrt(2)*cellSize);
    case 'right_down'
        f = imfilter(ZImin,right_down_core)/(sqrt(2)*cellSize); 
end
s = mean(f(:)); % s为坡度值
end

