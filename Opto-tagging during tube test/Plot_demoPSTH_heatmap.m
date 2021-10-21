
%% Plot PSTH  

periPush = PYR(31).periPush;  % choose the unit want to plot.

[m,n]=find(isnan(periPush)==1);
periPush(m,:)=[]

periPush=periPush(:,21:80)
numtrial=size(periPush,1);
periPush_mean=mean(periPush);
periPush_sem=std(periPush)/sqrt(numtrial);
times=-2:0.05:0.99;

figure
plot(times,periPush_mean,'k')
y1=periPush_mean+periPush_sem;
y2=periPush_mean-periPush_sem;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'r','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,periPush_mean,'k')
ylim([0,40]);


%% plot z-scored

periPush_Z = PV(3).periPush_Z;

[m,n]=find(isnan(periPush_Z)==1);
periPush_Z(m,:)=[]

periPush_Z=periPush_Z(:,21:80)


% figure
% imagesc(periPush_Z,[0,30])


figure
imagesc(periPush_Z,[-1,2])


