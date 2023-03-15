%%
clc,clear

%%
filename = 'concord_ortho_w.tif';
[X, cmap] = imread(filename);
worldFileName = getworldfilename(filename);
R = worldfileread(worldFileName, 'planar', size(X))

%% ����������
% ��ֵͼ��ʴ������ͼ��A�������ټ�һ��0��1������ֵ�����ԣ�
A = [0,0,1,0,0;
    0,1,1,0,0;
    1,0,0,1,0;
    0,1,1,1,1;
    0,1,1,1,1]
B = [0,1,0;
    1,1,1;
    0,1,0]
imerode(A,B)

% ��ֵͼ������
imdilate(A,B)

% ��ֵͼ��
imopen(A,B)


% �Ҷ�ͼ��ʴ
A = [246,66,150;
    88,216,141;
    150,69,366]

B = [0,1,0;
    1,1,1;
    0,1,0]

imerode(A,B)

imdilate(A,B)

%% ������������
A = [-398.110000000000,-398.030000000000,-398.050000000000;-397.850000000000,-399.250000000000,-400.820000000000;-397.550000000000,-398.370000000000,-400.590000000000]
B = [0,1,0;
    1,1,1;
    0,1,0]

Ae = imerode(A,B)

Aopen = imdilate(Ae,B)


%% �ݶȺ���
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

%% ����ֻ�е����ĵ���
M = dlmread("reference\samp11.txt");
gobs = ~M(:,4); % ȡ����1Ϊ�����
data = M(gobs,:);
figure
pcshow(data(:,1:3));
writematrix(data(:,1:3),'data.txt','Delimiter',' ') 

