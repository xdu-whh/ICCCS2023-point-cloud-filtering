%%
clc,clear

%%
filename = 'concord_ortho_w.tif';
[X, cmap] = imread(filename);
worldFileName = getworldfilename(filename);
R = worldfileread(worldFileName, 'planar', size(X))

%% 开操作测试
% 二值图像腐蚀（会在图像A的外面再加一层0和1，任意值都可以）
A = [0,0,1,0,0;
    0,1,1,0,0;
    1,0,0,1,0;
    0,1,1,1,1;
    0,1,1,1,1]
B = [0,1,0;
    1,1,1;
    0,1,0]
imerode(A,B)

% 二值图像膨胀
imdilate(A,B)

% 二值图像开
imopen(A,B)


% 灰度图像腐蚀
A = [246,66,150;
    88,216,141;
    150,69,366]

B = [0,1,0;
    1,1,1;
    0,1,0]

imerode(A,B)

imdilate(A,B)

%% 负数做开操作
A = [-398.110000000000,-398.030000000000,-398.050000000000;-397.850000000000,-399.250000000000,-400.820000000000;-397.550000000000,-398.370000000000,-400.590000000000]
B = [0,1,0;
    1,1,1;
    0,1,0]

Ae = imerode(A,B)

Aopen = imdilate(Ae,B)


%% 梯度函数
x = -2:0.2:2;
y = x';
z = x .* exp(-x.^2 - y.^2);
[px,py] = gradient(z);

[xm,ym] = meshgrid(x,y);
figure
mesh(x,y,z)

figure
contour(x,y,z)
hold on
quiver(x,y,px,py)
hold off

% test
A = [1,2,3,4;
    5,8,9,10;
    3,2,7,9]
[dx,dy] = gradient(A)

%% 
A = [1,4,10]
FX = gradient(A)

%% 导出只有地面点的点云
M = dlmread("reference\samp11.txt");
gobs = ~M(:,4); % 取反后：1为地面点
data = M(gobs,:);
figure
pcshow(data(:,1:3));
writematrix(data(:,1:3),'data.txt','Delimiter',' ') 

