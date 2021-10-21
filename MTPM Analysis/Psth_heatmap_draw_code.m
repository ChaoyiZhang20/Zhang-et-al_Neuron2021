event=liston(:,1)

numCell=size(data,1)
numEvent=size(event,1)
bin=1
    psth_t_pre = 200;
    psth_t_ing = 200;
    psth_t_post = 200;
    t = -psth_t_pre:bin:(psth_t_ing + psth_t_post);
    psth = zeros(numEvent, length(t), numCell);
   
    for i = 1:numCell
        for j = 1:numEvent
            idx_start = ceil(event(j)/bin) - floor(psth_t_pre/bin);
            idx_stop = ceil(event(j)/bin) + floor((psth_t_ing + psth_t_post)/bin);
            psth(j, :, i) = data(i, idx_start:idx_stop);
        end
    end
    
psth_mean_all = squeeze(mean(psth, 1))'
  

numcell= size(psth_mean,1)

mean_baseline= mean(psth_mean(:,1:200),2);

std_baseline = std(psth_mean(:,1:200),1,2);

for i = 1:numcell
    zscore(i,:)=smooth((psth_mean(i,:)-mean_baseline(i))/std_baseline(i),5);
end

psth_sign = zscore(:,(201:400));
mean_psth1 = mean(psth_sign,2);
psthmean=[mean_psth1,zscore];
psthsort=sortrows(psthmean,1); % 将matrix按照第一列进行升序排序，如果是降序则改为-1
psthsort1 = psthsort(:,2:601)

figure
imagesc(psthsort1,[-4,4])
colormap jet




