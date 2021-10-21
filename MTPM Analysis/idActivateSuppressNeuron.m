clc; clear;
close all;
[filename, pathname] = uigetfile('*.mat');
load(fullfile(pathname, filename));

data=PV_pos

listpre = [1601,1800;2401,2600;3201,3400;4001,4200;4801,5000;5601,5800;6401,6600;7201,7400;8001,8200;8801,9000];
liston = [1801,2000;2601,2800;3401,3600;4201,4400;5001,5200;5801,6000;6601,6800;7401,7600;8201,8400;9001,9200];
listpost=liston+400


%% 进行钙瞬变事件探测
% 参数 sigma 为采用的阈值，例如 sigma = 3 则是高于3倍标准差的探测结果
% transient 每一行代表一个神经元随时间的状态，1则处在 transient 期间
sigma = 4;
transient = transientDetection(data,sigma);

%% 探测完毕后进行计数
% 后两个参数不填写，则计数整个时间段发生钙瞬变事件的个数
% 若填写，则在指定时间段内计数，譬如下面是将1000~2000帧（100~200秒）进行计数
transientNum_1 = countTransient(transient);
%% transient 

for i = 1:size(liston, 1)
    for j = 1:size(transient, 1)
        pks_td_pre(j, i) = countTransient(transient(j,:),listpre(i, 1),listpre(i, 2));
       pks_td_on(j, i) = countTransient(transient(j,:),liston(i, 1),liston(i, 2));
       pks_td_post(j, i) = countTransient(transient(j,:),listpost(i, 1),listpost(i, 2));
    end
end
%% 
%计算auc
z=data
for i = 1:size(liston, 1)
    auc_td_pre(:, i) = mean(z(:, listpre(i, 1):listpre(i, 2)), 2);
    auc_td_on(:, i) = mean(z(:, liston(i, 1):liston(i, 2)), 2);
    auc_td_post(:, i) = mean(z(:, listpost(i, 1):listpost(i, 2)), 2);
end

%auc 统计
auc_td = [auc_td_pre, auc_td_on];
imagesc(auc_td)
for i = 1:size(auc_td_pre, 1)
    [h1(i, 1), p1(i, 1)] = ttest(auc_td_pre(i, :), auc_td_on(i, :));
    r1(i, :) = (auc_td_on(i, :)-auc_td_pre(i, :)) ./ (auc_td_on(i, :)+auc_td_pre(i, :));
end
r1 = mean(r1, 2, 'omitnan');

idx1_sig_nega = find(r1<0 & h1 == 1)
idx1_sig_pos = find(r1>0 & h1 == 1)


%pks 统计
pks_td = [pks_td_pre, pks_td_on];
imagesc(pks_td)
for i = 1:size(pks_td_pre, 1)
    [h2(i, 1), p2(i, 1)] = ttest(pks_td_pre(i, :), pks_td_on(i, :));
    r2(i, :) = (pks_td_on(i, :)-pks_td_pre(i, :)) ./ (pks_td_on(i, :)+pks_td_pre(i, :));
end
r2 = mean(r2, 2, 'omitnan');

idx2_sig_nega = find(r2<0 & h2 == 1)
idx2_sig_pos = find(r2>0 & h2 == 1)

% figure
% scatter(p, r)


mean_auc_td_on=mean(auc_td_on');
mean_auc_td_pre=mean(auc_td_pre')
mean_auc_td_post=mean(auc_td_post')
auc=[mean_auc_td_pre',mean_auc_td_on',mean_auc_td_post']


mean_pks_td_on=mean(pks_td_on');
mean_pks_td_pre=mean(pks_td_pre')
mean_pks_td_post=mean(pks_td_post')
pks=[mean_pks_td_pre',mean_pks_td_on',mean_pks_td_post']
