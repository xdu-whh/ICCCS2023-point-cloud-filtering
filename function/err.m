function [err1,err2,e,K] = err(varargin)
%ERR ��������˲������
% ��������:
% item1: ����һ��N*2�ľ�������һ������ʵ�ĵ������һ����Ԥ������
% item2: ����������������һ��������N*1�ľ��󣬱�ʾ��Ԥ��Ϊ������Ƶ�����(�����е�����Ϊ��ʵ���)
%        ��һ����M*1�ľ��󣬱�ʾ��Ԥ��Ϊ�ǵ��������(�����е�����Ϊ��ʵ���)
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
    r1(:,1) = data_ground; % ��һ�д��ʵ�ʽ�����ڶ�����Ԥ����
    r2(:,1) = data_off_ground; 
    r = [r1;r2];
    ct = crosstab(r(:,1),r(:,2));
end

%   ct��2*2�Ļ�������
err1 = ct(1,2)/(ct(1,1)+ct(1,2));
err2 = ct(2,1)/(ct(2,1)+ct(2,2));
e = (ct(1,2)+ct(2,1))/sum(ct(:));
% Kappa
K = Kappa(ct);
sprintf('��һ�����:%0.2f%%,�ڶ������Ϊ:%0.2f%%,�����Ϊ:%0.2f%%,Kappaϵ��Ϊ:%0.2f%%',err1*100,err2*100,e*100,K*100)
end

