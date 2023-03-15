%%
clc,clear
close all
warning('off')

%% ��ȡ����
inpaintMethod = 4;
% ��ȡ����
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
    
    % ��ȡ����
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
    
%% ����ͶӰ
    [ZImin R isEmptyCell xi yi] = createDSM(x,y,z,...
                                        'c',cellSize,'type','min','inpaintMethod',inpaintMethod);
    ZImin(isEmptyCell) = NaN;
%% ˮ���������
% ʹ��ˮ���Ե����Сֵ��ˮ��������
% �ҵ�ˮ���Ե���ͼ���ж�ӦZImin����Сֵ��ʹ�����Ͳ���
% �����뿪�����Ľ���ཻ��ֱ���������仯Ϊֹ
% ��ʱ�����һ��ˮ�塣�����ˮ�����Ϊ��Сֵ��
% ���������Ľ�����������͵Ľ����������ܹ��õ���������һ��
% �����ˮ���ͼ�񣬶��������̽��е�����ֱ������ˮ�屻���
    se_open = strel('disk',5);
    se_dilate = strel('disk',1);
    se_conn = strel('rectangle',[3,3]); % 8��ͨ���
    % ��isEmptyCell���п�����������ˮ����
    water_detect = imopen(isEmptyCell,se_open);
    while(any(water_detect,'all')) % �Ƿ�����ˮ�嶼�õ����,ÿ��ѭ�����һ��ˮ��
    % ��Ե���
    water_edge = imdilate(water_detect,se_dilate) - water_detect;
    % �ҳ���Ե��Сֵ�Լ�����λ��
    edge_img = zeros(size(ZImin)) + inf;
    edge_img(logical(water_edge)) = ZImin(logical(water_edge));
    [r,c] = find(edge_img==min(edge_img(:))); % ��Сλ�ö�Ӧ���к���
    % �������ӵ�(r,c)����������
    X_old = logical(zeros(size(ZImin)));
    X_old(r,c) = 1;
    X_new = imdilate(X_old,se_conn) & water_detect;
    while(any(X_new-X_old,'all')) % ѭ��������õ���ͨ��
       X_old = X_new;
       X_new = imdilate(X_old,se_conn) & water_detect;
    end
    % ����ͨ������λ�����Ϊ��Сֵ��
    ZImin(X_new) = min(edge_img(:));
    % ��ȥ��⵽����ͨ��
    water_detect = water_detect - X_new;
    end

%% ȱʧֵ���
    ZImin = inpaint_nans(ZImin,inpaintMethod);

%% ��ZIminת��Ϊ�Ҷ�ͼ��
    img = cast(mat2gray(ZImin)*255,'uint8');
%     figure
%     imshow(img)
%     title("�Ҷ�ͼ��")

%% ���ڰ뾶�Զ���(��λ������)
    w = window_detect(img);
    w = w*cellSize; % ���˲������ڰ뾶��С��λת��Ϊm

%% �����˲�
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

%% �����������ͼ
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






