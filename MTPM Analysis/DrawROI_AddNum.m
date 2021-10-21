close all; %��ȫ������
clear;  %�������
clc;    %��������д���
dbstop if error; %����ʱͣ���ڳ�����

load('RoiMskSet.mat');
%load('modulation_index'); %�������ݣ�����Ӧ����RoiMskSet�Ͷ�Ӧ��ָ�꡾�ɸġ�

RoiMskSet = double(logical(RoiMskSet)); %��RoiMskSet��512*512*ROI�������double�ͣ����Ᵽ������ʱ��single����������
Center = zeros(size(RoiMskSet,3),2);    %�½�һ��Center���飬ά��N*2��NΪROI������
for i=1:size(RoiMskSet,3)   %ѭ��
    Msk = RoiMskSet(:,:,i); %ȡRoiMskSet�ĵ�i�㣬Ҳ���ǵ�i��ROI����СΪ512*512
    props = regionprops(Msk,'Centroid'); %��ȡROI������
    Center(i,:) = round(props.Centroid); %��ROI���Ĵ�double��ת�����ͣ����ں���������֡�
end %ѭ������

colorbar_range = [0,1.2]; %����colorbar��ȡֵ��Χ���ɸġ�
colormapNum = 250; %�̶�colormap��������ֻ��colormapNum����ɫ��ѡ���������
cmap0 = colormap(b2r_2(-3,3,colormapNum)); %ʹ��colormap�������ɲ�ͬ����ɫ��b2r_2�����ɺ�-��colormap�ĺ�����-3��������3����죬������ġ�
% ע�⣬Ŀǰ��cmap0���һ�д����������ɫ��RGBֵ�����һ�д���������ɫ��RGBֵ��
close all; % �ص����д��ڣ�ԭ����ʹ��colormap����ʱ���Զ�����һ��Figure����

cmap = zeros(size(RoiMskSet,3),3); %�½�һ��cmap��ά��ΪN*3��׼����¼ÿһ��ROI��RGBֵ��
for i=1:size(RoiMskSet,3) %ѭ��
    index = modulation_index(i,1); %��ȡ��i��ROI����Ӧ����ֵ
    rankratio = (index - colorbar_range(1,1))/(colorbar_range(1,2)-colorbar_range(1,1)); %��ȡindexֵ��colorbarȡֵ��Χ�ڵİٷ�λ
    cmaptmp = cmap0(max(1,round(colormapNum*rankratio)),:); %���ݰٷ�λ������cmap0�л�ȡRGBֵ��
    % ˵����colormapNum*rankratio��ʾ��cmap0�ж�Ӧ�ٷ�λ����ֵ�Ƕ��٣�round��ȡ����max(1,~)������֤���ǵ�rankratioΪ0ʱ����ȡ����cmap0�ĵ�һ��RGBֵ��
    cmap(i,:) = cmaptmp; %cmap�ĵ�i��Ϊcmaptmp;
end %ѭ������


I = ones(size(RoiMskSet,1),size(RoiMskSet,2))*255; %����һ����������һ����̶�������С����һ����Ϊ��ɫ��������ɫ��uint8��Ϊ��255,255,255����
% ע��û�а�ɫ����ֱ��plotҲ���ԣ�������Ҫ��figure�е�axis�ķ�Χ�����ҶԱ߽���Ҫ����������һ�㲻��ô����
figure(1); % ����figure(1)�����ڼ�¼���������
imshow(uint8(I),[]); %��ʾ��ɫ����
hold on; % ����ͼ��
for idx=1:size(RoiMskSet,3) %ѭ�����ROI
    Msktmp = RoiMskSet(:,:,idx); %��ȡ��idx��ROI
    colormat = cmap(idx,:); %��ȡ��Ӧ����ɫ��ֵΪ(R,G,B)
    [B,~] = bwboundaries(Msktmp,'noholes'); %����ROI��õ�idx��ROI�ı߽�Ԫ������
    tmp_boundary = B{1,1}; %��ȡ��idx��ROI�ı߽�����
    xxx = tmp_boundary(:,2); %��ȡx����������ȡ��2���ԭ���ǻ�ͼʱ�������;������������֮�����ת�ù�ϵ
    yyy = tmp_boundary(:,1); %��ȡy��������
    plot(xxx,yyy,'k-','linewidth',1); %��figure(1)�ϻ���idx��ROI�ı߽磬linewidthΪ�ɵ����߿�
    hold on %����ͼ��
    fill(xxx,yyy,colormat); %���߽�������Ӧ����ɫ
end %ѭ������

figure(1); %������figure(1)��׼������
hold on; %����ͼ��
FontSize = 6; %����������ֺš��ɸġ�
for i=1:size(RoiMskSet,3) % ѭ���������
    text(max(1,Center(i,1)-round(FontSize/2)),Center(i,2),num2str(i),'color','k','FontSize',FontSize); %�ڵ�i����������Ĵ������������
    % ˵����Center(i,1)-round(FontSize/2)��ԭ�������ֵ����ĺ�ROI�������غϣ�num2str(i)Ϊ��Ҫ�ӵ��֡��ɸġ���'color'��'k'�����Ǻ�ɫ��
    hold on; %����ͼ��
end

% ����������figure(1)�м���һ����ɫ�ı�����ֱ���������colorbarʱ����ɫ����Ҳ����Ӱ�졣
% ��������½�һ��figure,��¼colorbar�����������ͼ��
figure(2); %�½�һ��figure,����Ϊfigure(2)
colormap(cmap0),colorbar,caxis(colorbar_range); %��ʾcmap0��colorbar�͹涨��ȡֵ��Χ






