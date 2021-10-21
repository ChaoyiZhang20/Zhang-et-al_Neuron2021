
%% 计算双光子数据各个区间的auc\tran\significant change

clc,clear,close all

%% 设置数据路径并导入
dataPath = '2P-0624';
load(fullfile(dataPath,'2P-all Good cell-raw.mat'));

%% 保留信噪比高的神经元
thre = 0.003;
[keepId,~] = traceQualityEval(trace,trace_ring,dff,thre);
dff_good = dff(keepId,:);

%% 进行钙瞬变事件探测
% 参数 sigma 为采用的阈值，例如 sigma = 3 则是高于3倍标准差的探测结果
% transient 每一行代表一个神经元随时间的状态，1则处在 transient 期间
sigma = 4;
transient = transientDetection(PV_neg,sigma);

%% 探测完毕后进行计数
% 后两个参数不填写，则计数整个时间段发生钙瞬变事件的个数
% 若填写，则在指定时间段内计数，譬如下面是将1000~2000帧（100~200秒）进行计数
transientNum_1 = countTransient(transient);


%计算光照前区间的钙瞬变事件的个数
listpre = [1601,1800;2401,2600;3201,3400;4001,4200;4801,5000;5601,5800;6401,6600;7201,7400;8001,8200;8801,9000];
tran_lightonpre = 0;
for i = 1:size(listpre,1)
    tran_lightonpre = tran_lightonpre + countTransient(transient,listpre(i,1),listpre(i,2));
end
%计算光照区间的钙瞬变事件的个数
liston = [1801,2000;2601,2800;3401,3600;4201,4400;5001,5200;5801,6000;6601,6800;7401,7600;8201,8400;9001,9200];
tran_lighton = 0;
for i = 1:size(liston,1)
    tran_lighton = tran_lighton + countTransient(transient,liston(i,1),liston(i,2));
end

%计算光照后区间的钙瞬变事件的个数
listpost = [2001,2200;2801,3000;3601,3800;4401,4600;5201,5400;6001,6200;6801,7000;7601,7800;8401,8600;9201,9400];
tran_lightpost = 0;
for i = 1:size(listpost,1)
    tran_lightpost = tran_lightpost + countTransient(transient,listpost(i,1),listpost(i,2));
end

modulation_index = tran_lighton./(tran_lighton + tran_lightpost)
modulation_index2 = tran_lighton./(tran_lighton + tran_lightonpre)

%计算照光与不照光区间的平均值
auc_lightonpre=VIP_neg(:,[1601:1800 2401:2600 3201:3400 4001:4200 4801:5000 5601:5800 6401:6600 7201:7400 8001:8200 8801:9000]);

auc_lighton=VIP_neg(:,[1801:2000 2601:2800 3401:3600 4201:4400 5001:5200 5801:6000 6601:6800 7401:7600 8201:8400 9001:9200]);

auc_lightpost=VIP_neg(:,[2001:2200 2801:3000 3601:3800 4401:4600 5201:5400 6001:6200 6801:7000 7601:7800 8401:8600 9201:9400]);

mean_auclightonpre = [sum(auc_lightonpre(:, 1:200), 2), mean(auc_lightonpre(:, 201:400), 2), mean(auc_lightonpre(:, 401:600), 2), mean(auc_lightonpre(:, 601:800), 2), mean(auc_lightonpre(:, 801:1000), 2),mean(auc_lightonpre(:, 1001:1200), 2), mean(auc_lightonpre(:, 1201:1400), 2), mean(auc_lightonpre(:, 1401:1600), 2), mean(auc_lightonpre(:, 1601:1800), 2), mean(auc_lightonpre(:, 1801:2000), 2)]

mean_auclighton = [mean(auc_lighton(:, 1:200), 2), mean(auc_lighton(:, 201:400), 2), mean(auc_lighton(:, 401:600), 2), mean(auc_lighton(:, 601:800), 2), mean(auc_lighton(:, 801:1000), 2),mean(auc_lighton(:, 1001:1200), 2), mean(auc_lighton(:, 1201:1400), 2), mean(auc_lighton(:, 1401:1600), 2), mean(auc_lighton(:, 1601:1800), 2), mean(auc_lighton(:, 1801:2000), 2)]

mean_auclightpost = [mean(auc_lightpost(:, 1:200), 2), mean(auc_lightpost(:, 201:400), 2), mean(auc_lightpost(:, 401:600), 2), mean(auc_lightpost(:, 601:800), 2), mean(auc_lightpost(:, 801:1000), 2),mean(auc_lightpost(:, 1001:1200), 2), mean(auc_lightpost(:, 1201:1400), 2), mean(auc_lightpost(:, 1401:1600), 2), mean(auc_lightpost(:, 1601:1800), 2), mean(auc_lightpost(:, 1801:2000), 2)];

auc_lightonpresum=sum(mean_auclightonpre,2);
auc_lightonsum=sum(mean_auclighton,2);
auc_lightpostsum=sum(mean_auclightpost,2)

M1= auc_lightonsum./(auc_lightonsum + auc_lightpostsum)
M2= auc_lightonsum./(auc_lightonpresum + auc_lightonsum)

r=size(VIP_neg,1)

%这个用来计算不同照光前后的transient 总和

sumpre_calevents = [countTransient(transient,1601,1800), countTransient(transient,2401,2600), countTransient(transient,3201,3400), countTransient(transient,4001,4200), countTransient(transient,4801,5000), countTransient(transient,5601,5800), sum(transient(:, 6401:6600), 2), sum(transient(:, 7201:7400), 2), sum(transient(:, 8001:8200), 2), sum(transient(:, 8801:9000), 2)];
suming_calevents = [sum(transient(:, 1801:2000), 2), sum(transient(:, 2601:2800), 2), sum(transient(:, 3401:3600), 2), sum(transient(:, 4201:4400), 2), sum(transient(:, 5001:5200), 2), sum(transient(:, 5801:6000), 2), sum(transient(:, 6601:6800), 2), sum(transient(:, 7401:7600), 2), sum(transient(:, 8201:8400), 2), sum(transient(:, 9001:9200), 2)];
sumpost_calevents = [sum(transient(:, 2001:2200), 2), sum(transient(:, 2801:3000), 2), sum(transient(:, 3601:3800), 2), sum(transient(:, 44201:4600), 2), sum(transient(:, 5201:5400), 2), sum(transient(:, 6001:6200), 2), sum(transient(:, 6801:7000), 2), sum(transient(:, 7601:7800), 2), sum(transient(:, 8401:8600), 2), sum(transient(:, 9201:9400), 2)];
 for i = 1:r 
p1(i) = signrank(sumpre_calevents(i,:),suming_calevents(i,:))
p2(i) = signrank(sumpost_calevents(i,:),suming_calevents(i,:))
 end

 %这个用来计算不同照光前后的AUC 总和

meanpre_AUC = [mean(VIP_neg(:, 1601:1800), 2), mean(VIP_neg(:, 2401:2600), 2), mean(VIP_neg(:, 3201:3400), 2), mean(VIP_neg(:, 4001:4200), 2), mean(VIP_neg(:, 4801:5000), 2), mean(VIP_neg(:, 5601:5800), 2), mean(VIP_neg(:, 6401:6600), 2), mean(VIP_neg(:, 7201:7400), 2), mean(VIP_neg(:, 8001:8200), 2), mean(VIP_neg(:, 8801:9000), 2)];
meaning_AUC = [mean(VIP_neg(:, 1801:2000), 2), mean(VIP_neg(:, 2601:2800), 2), mean(VIP_neg(:, 3401:3600), 2), mean(VIP_neg(:, 4201:4400), 2), mean(VIP_neg(:, 5001:5200), 2), mean(VIP_neg(:, 5801:6000), 2), mean(VIP_neg(:, 6601:6800), 2), mean(VIP_neg(:, 7401:7600), 2), mean(VIP_neg(:, 8201:8400), 2), mean(VIP_neg(:, 9001:9200), 2)];
meanpost_AUC = [mean(VIP_neg(:, 2001:2200), 2), mean(VIP_neg(:, 2801:3000), 2), mean(VIP_neg(:, 3601:3800), 2), mean(VIP_neg(:, 4401:4600), 2), mean(VIP_neg(:, 5201:5400), 2), mean(VIP_neg(:, 6001:6200), 2), mean(VIP_neg(:, 6801:7000), 2), mean(VIP_neg(:, 7601:7800), 2), mean(VIP_neg(:, 8401:8600), 2), mean(VIP_neg(:, 9201:9400), 2)];
 for i = 1:r
p3(i) = signrank(meanpre_AUC(i,:),meaning_AUC(i,:))
p4(i) = signrank(meanpost_AUC(i,:),meaning_AUC(i,:))
 end

 
%计算 pre on 和 post 的 auc 和 tran 
auc= [auc_lightonpresum,auc_lightonsum,auc_lightpostsum]
tran= [tran_lightonpre,tran_lighton,tran_lightpost]
 
i = 2; % 调节这个变量可以看不同神经元的 transient
figure
subplot(2,1,1),plot(VIP_neg(i,:))
subplot(2,1,2),plot(VIP_neg(i,:).*transient(i,:))
suptitle(['第',num2str(i),'个神经元钙信号及其 transient'])

figure
imagesc(transient)
title('所有神经元的transient概览')

p=[p1;p2;p3;p4]
p=p'