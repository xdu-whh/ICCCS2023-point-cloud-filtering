function K = Kappa(ct)
%Kappa ���ڼ������������Kappaϵ��
%   �˴���ʾ��ϸ˵��
% K��Kappaֵ
% ct�����������Ļ�������
Po = trace(ct)/sum(ct(:));
Pe = sum(ct,1)*sum(ct,2)/(sum(ct(:)))^2;
K = (Po - Pe)/(1 - Pe);
end

