close all; %关全部窗口
clear;  %清除变量
clc;    %清空命令行窗口
dbstop if error; %出错时停留在出错行

load('RoiMskSet.mat');
%load('modulation_index'); %读入数据，里面应该有RoiMskSet和对应的指标【可改】

RoiMskSet = double(logical(RoiMskSet)); %将RoiMskSet（512*512*ROI数）变成double型，避免保存数据时是single等其他类型
Center = zeros(size(RoiMskSet,3),2);    %新建一个Center数组，维度N*2，N为ROI的数量
for i=1:size(RoiMskSet,3)   %循环
    Msk = RoiMskSet(:,:,i); %取RoiMskSet的第i层，也就是第i个ROI，大小为512*512
    props = regionprops(Msk,'Centroid'); %提取ROI的质心
    Center(i,:) = round(props.Centroid); %将ROI质心从double型转成整型，便于后面添加文字。
end %循环结束

colorbar_range = [0,1.2]; %设置colorbar的取值范围【可改】
colormapNum = 250; %固定colormap的数量，只有colormapNum种颜色可选，不建议改
cmap0 = colormap(b2r_2(-3,3,colormapNum)); %使用colormap函数生成不同的颜色，b2r_2是生成红-蓝colormap的函数，-3是深蓝，3是深红，不建议改。
% 注意，目前在cmap0里，第一行代表的是深蓝色的RGB值，最后一行代表的是深红色的RGB值。
close all; % 关掉所有窗口，原因是使用colormap函数时会自动弹出一个Figure窗口

cmap = zeros(size(RoiMskSet,3),3); %新建一个cmap，维度为N*3，准备记录每一个ROI的RGB值。
for i=1:size(RoiMskSet,3) %循环
    index = modulation_index(i,1); %获取第i个ROI所对应的数值
    rankratio = (index - colorbar_range(1,1))/(colorbar_range(1,2)-colorbar_range(1,1)); %获取index值在colorbar取值范围内的百分位
    cmaptmp = cmap0(max(1,round(colormapNum*rankratio)),:); %根据百分位数，在cmap0中获取RGB值。
    % 说明：colormapNum*rankratio表示在cmap0中对应百分位的数值是多少，round是取整，max(1,~)函数保证的是当rankratio为0时，获取的是cmap0的第一行RGB值。
    cmap(i,:) = cmaptmp; %cmap的第i行为cmaptmp;
end %循环结束


I = ones(size(RoiMskSet,1),size(RoiMskSet,2))*255; %创建一个画布矩阵，一方面固定画布大小，另一方作为白色背景，白色在uint8中为（255,255,255）。
% 注：没有白色背景直接plot也可以，但是需要调figure中的axis的范围，并且对边界需要做调整，我一般不这么做。
figure(1); % 创建figure(1)，用于记录胞体的坐标
imshow(uint8(I),[]); %显示白色画布
hold on; % 增加图层
for idx=1:size(RoiMskSet,3) %循环添加ROI
    Msktmp = RoiMskSet(:,:,idx); %获取第idx个ROI
    colormat = cmap(idx,:); %获取对应的颜色，值为(R,G,B)
    [B,~] = bwboundaries(Msktmp,'noholes'); %根据ROI获得第idx个ROI的边界元胞数组
    tmp_boundary = B{1,1}; %获取第idx个ROI的边界坐标
    xxx = tmp_boundary(:,2); %获取x坐标向量，取第2项的原因是画图时的索引和矩阵变量的索引之间存在转置关系
    yyy = tmp_boundary(:,1); %获取y坐标向量
    plot(xxx,yyy,'k-','linewidth',1); %在figure(1)上画第idx个ROI的边界，linewidth为可调的线宽
    hold on %增加图层
    fill(xxx,yyy,colormat); %将边界内填充对应的颜色
end %循环结束

figure(1); %还是在figure(1)，准备填字
hold on; %增加图层
FontSize = 6; %设置字体的字号【可改】
for i=1:size(RoiMskSet,3) % 循环添加文字
    text(max(1,Center(i,1)-round(FontSize/2)),Center(i,2),num2str(i),'color','k','FontSize',FontSize); %在第i个胞体的质心处附近添加文字
    % 说明：Center(i,1)-round(FontSize/2)的原因是让字的质心和ROI的质心重合，num2str(i)为所要加的字【可改】，'color'的'k'代表是黑色。
    hold on; %增加图层
end

% 由于我们在figure(1)中加了一个白色的背景，直接在上面加colorbar时，白色背景也会受影响。
% 因此我们新建一个figure,记录colorbar，方便后续作图。
figure(2); %新建一个figure,名字为figure(2)
colormap(cmap0),colorbar,caxis(colorbar_range); %显示cmap0，colorbar和规定的取值范围






