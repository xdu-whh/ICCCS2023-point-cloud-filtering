%% ��ʼ��
clc,clear
close all

%% ��������
data = load('reference/samp11.txt')
data_ground = load('ground points.txt');
data_off_ground = load("off-ground points.txt");

%% ����Ϊ�������������ж�������ʵ�ķǵ����
c = sum(data_ground(:,4))  % �ǵ����
a =  size(data_ground,1) - c

%% ����Ϊ�������������ж�������ʵ�ķǵ����
b = sum(data_off_ground(:,4))
d = size(data_off_ground,1) - b

%% ���
err1 = b/(a+b)
err2 = d/(c+d)