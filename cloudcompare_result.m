%% 初始化
clc,clear
close all

%% 导入数据
data = load('reference/samp11.txt')
data_ground = load('ground points.txt');
data_off_ground = load("off-ground points.txt");

%% 被判为地面点的数据中有多少是真实的非地面点
c = sum(data_ground(:,4))  % 非地面点
a =  size(data_ground,1) - c

%% 被判为地面点的数据中有多少是真实的非地面点
b = sum(data_off_ground(:,4))
d = size(data_off_ground,1) - b

%% 误差
err1 = b/(a+b)
err2 = d/(c+d)