
b=psth1 % psth1 is a matrix of specific behavior psth
figure
imagesc(b,[-5,5])


numtrial=size(b,1)
b_mean=mean(b)
b_sem=std(b)/sqrt(numtrial)
times=-3:0.02:3.98

figure
plot(times,b_mean,'k')
y1=b_mean+b_sem;
y2=b_mean-b_sem;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'black','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,b_mean,'k')
hold on
ylim([-3,4])

%计算significance

baseline = [-3, -1];
bin = 0.1;
xbin = min(times):bin:max(times);

idx_sample1 = find(times >= baseline(1) & times <= baseline(2));
sample1 = psth1(:, idx_sample1);
sample1 = mean(sample1, 2);

for i = 1:length(xbin)-1
    idx_sample2 = find(times >= xbin(i) & times <= xbin(i+1));
    sample2 = psth1(:, idx_sample2);
    sample2 = mean(sample2, 2);
    [~, p1(i)] = ttest2(sample1, sample2);
    [p2(i),~,~]=permutationTest(sample1,sample2,500);
end


psth1_mean=b_mean


% scatter(times(idx1),psth1_mean(idx1), 10, 'r','filled')

p2_corrected = mafdr(p2, 'BHFDR', true);
idx = find(p2_corrected<0.05);
idx1 = [];
for i = 1:length(idx)
    idx1 = [idx1, find(times>=xbin(idx(i)) & times <= xbin(idx(i)+1))];
end
scatter(times(idx1),psth1_mean(idx1),10,'r','filled')
idx2=setdiff(1:times, idx1);
hold on
scatter(times(idx2),psth1_mean(idx2),10,'b','filled')
