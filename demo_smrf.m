%%
clc,clear
close all
warning('off')

%% 读取数据
inpaintMethod = 4;
% 读取数据
samp = {
    'samp11',
    'samp12',
    'samp21',
    'samp22',
    'samp23',
    'samp24',
    'samp31',
    'samp41',
    'samp42',
    'samp51',
    'samp52',
    'samp53',
    'samp54',
    'samp61',
    'samp71'
}
E1 = zeros(length(samp),1);
E2 = zeros(length(samp),1);
ET = zeros(length(samp),1);
Kappa = zeros(length(samp),1);
for i=1:length(samp)
    file = [samp{i,1},'.txt']
    M = dlmread(file);
    x = M(:,1);
    y = M(:,2);
    z = M(:,3);
    gobs = M(:,4);  % 0 is Ground, 1 is Object
    clear M;
    
    % 读取参数
    parameter = dlmread('parameter.txt');
    for j=1:size(parameter,1)
        if strcmp(num2str(parameter(j,1)),file(5:6))
            p = parameter(j,:);
        end
    end
    
    cellSize = 1;
    s = p(2);
%     w = p(3);
    et = p(4);
    es = p(5);
    
%% 点云投影
    [ZImin R isEmptyCell xi yi] = createDSM(x,y,z,...
                                        'c',cellSize,'type','min','inpaintMethod',inpaintMethod);
    ZImin(isEmptyCell) = NaN;
%% 水体检测与填充
% 使用水体边缘的最小值对水体进行填充
% 找到水体边缘检测图像中对应ZImin的最小值，使用膨胀操作
% 并且与开操作的结果相交，直到不发生变化为止
% 此时便检测出一个水体。将这个水体填充为最小值。
% 将开操作的结果与连续膨胀的结果相减，便能够得到不包括第一个
% 被填充水体的图像，对上述过程进行迭代。直到所有水体被填充
    se_open = strel('disk',5);
    se_dilate = strel('disk',1);
    se_conn = strel('rectangle',[3,3]); % 8联通检测
    % 对isEmptyCell进行开操作，进行水体检测
    water_detect = imopen(isEmptyCell,se_open);
    while(any(water_detect,'all')) % 是否所有水体都得到填充,每次循环检测一个水体
    % 边缘检测
    water_edge = imdilate(water_detect,se_dilate) - water_detect;
    % 找出边缘最小值以及所在位置
    edge_img = zeros(size(ZImin)) + inf;
    edge_img(logical(water_edge)) = ZImin(logical(water_edge));
    [r,c] = find(edge_img==min(edge_img(:))); % 最小位置对应的行和列
    % 根据种子点(r,c)，进行膨胀
    X_old = logical(zeros(size(ZImin)));
    X_old(r,c) = 1;
    X_new = imdilate(X_old,se_conn) & water_detect;
    while(any(X_new-X_old,'all')) % 循环结果，得到联通集
       X_old = X_new;
       X_new = imdilate(X_old,se_conn) & water_detect;
    end
    % 将联通集所在位置填充为最小值。
    ZImin(X_new) = min(edge_img(:));
    % 减去检测到的联通集
    water_detect = water_detect - X_new;
    end

%% 缺失值填充
    ZImin = inpaint_nans(ZImin,inpaintMethod);

%% 将ZImin转化为灰度图像
    img = cast(mat2gray(ZImin)*255,'uint8');
%     figure
%     imshow(img)
%     title("灰度图像")

%% 窗口半径自动化(单位：像素)
    w = window_detect(img);
    w = w*cellSize; % 将滤波窗窗口半径大小单位转化为m

%% 点云滤波
    [ZI R gest] = smrf(x,y,z,'c',cellSize,'s',s,'w',w,'et',et,'es',es);
    [err1,err2,e,K] = err([gobs,gest]);
    E1(i,1) = err1;
    E2(i) = err2;
    ET(i) = e;
    Kappa(i) = K;
    fig = view_result([x,y,z,gobs,gest]);
    f = getframe(fig);
    imwrite(f.cdata,['figures/',file(1:6),'_result','.png'])
end

result_table = table(E1*100,E2*100,ET*100,Kappa*100);
writetable(result_table,'result.xlsx','Sheet',1)

%% 绘制误差折线图
s = 1:1:15;
figure
plot(s,E1,'o-','linewidth',1.2,'Color','#0072BD');
hold on
plot(s,E2,'*-','linewidth',1.2,'Color',	'#D95319');
plot(s,ET,'x-','linewidth',1.2,'Color','#EDB120')
grid on
set(gca,'xtick',[1:1:15])
xlabel('Sample number','FontSize',18)
ylabel('Error','FontSize',18)
title('Results','FontSize',18)

yyaxis right
plot(s,Kappa,'+-','linewidth',1.2)
ylabel('Kappa','FontSize',18)
legend({'Type I error','Type II error','Total Error','Kappa'})






