function [err1,err2,e,K] = err(varargin)
%ERR 计算点云滤波的误差
% 两种输入:
% item1: 输入一个N*2的矩阵，其中一列是真实的点云类别，一列是预测的类别
% item2: 输入两个参数，第一个参数是N*1的矩阵，表示被预测为地面点云的数据(矩阵中的数字为真实类别)
%        另一个是M*1的矩阵，表示被预测为非地面的数据(矩阵中的数字为真实类别)
if length(varargin) == 1
    r = varargin{1};
    ct = crosstab(r(:,1),r(:,2));
else
    i = 1;
    while i<length(varargin)
        if isstr(varargin{i})
           switchstr = lower(varargin{i}); 
           switch switchstr
               case 'ground'
                   data_ground = varargin{i+1};
               case 'off-ground'
                   data_off_ground = varargin{i+1};
           end
        end
        i =i+1;
    end
    r1 = zeros(size(data_ground,1),2);
    r2 = ones(size(data_off_ground,1),2);
    r1(:,1) = data_ground; % 第一列存放实际结果，第二列是预测结果
    r2(:,1) = data_off_ground; 
    r = [r1;r2];
    ct = crosstab(r(:,1),r(:,2));
end

%   ct是2*2的混淆矩阵
err1 = ct(1,2)/(ct(1,1)+ct(1,2));
err2 = ct(2,1)/(ct(2,1)+ct(2,2));
e = (ct(1,2)+ct(2,1))/sum(ct(:));
% Kappa
K = Kappa(ct);
sprintf('第一类误差:%0.2f%%,第二类误差为:%0.2f%%,总误差为:%0.2f%%,Kappa系数为:%0.2f%%',err1*100,err2*100,e*100,K*100)
end

