function K = Kappa(ct)
%Kappa 用于计算二分类结果的Kappa系数
%   此处显示详细说明
% K：Kappa值
% ct：二分类结果的混淆矩阵
Po = trace(ct)/sum(ct(:));
Pe = sum(ct,1)*sum(ct,2)/(sum(ct(:)))^2;
K = (Po - Pe)/(1 - Pe);
end

