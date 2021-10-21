
clc; clear; 
close all;

%%  load data
folderAddress='G:\ZCY-2021-rebuttal data\0701-Tagging analysis';
load([folderAddress,'\Output new\v2-PYR_PETH.mat']);
load([folderAddress,'\Output new\v2-PYRstat.mat']);
%% Plot avereage PV neuroPV heatmap

numtrial=size(PYR,2);
for i = 1:numtrial
    PYR(i).periRetreat_Z(isnan(PYR(i).periRetreat_Z)) = 0;   
    deletidx=[];
    for jj=1:size(PYR(i).periRetreat_Z,1);
        if ~isempty(find(isinf(PYR(i).periRetreat_Z(jj,:))))
            deletidx=[deletidx,jj];
        else
        end
    end
    PYR(i).periRetreat_Z(deletidx,:)=[];  %% delete rows with inf value
    mean_c(i)=nanmean(mean(PYR(i).periRetreat_Z(:, 41:100), 2));
end
[~, idx_sort] = sort(mean_c, 'descend');

for i=1:numtrial
    PYR_retreat_mean_psth(i,:)=nanmean(PYR(idx_sort(i)).periRetreat_Z);
end

figure
imagesc(PYR_retreat_mean_psth(:,1:140),[-1,2])
colormap jet
%% Plot sign psth
for ii = 1:267
    retreat_p2(ii)=PYRstat(ii).retreat_P2;
    retreat_r2(ii)=PYRstat(ii).retreat_CI2;
end

idx_act=find(retreat_p2<0.05 & retreat_r2>0);
idx_inb=find(retreat_p2<0.05 & retreat_r2<0);

% Plot sign_Act psth

act_periRetreat_Z =zeros(1,160);

for ii= 1:size(idx_act,2)
    act_periRetreat_Z  =cat(1,act_periRetreat_Z ,PYR(idx_act(ii)).periRetreat_Z);
end
[m,n]=find(isnan(act_periRetreat_Z )==1);
act_periRetreat_Z (m,:)=[];

act_periRetreat_Z =act_periRetreat_Z (:,1:140);
numtrial=size(PYR,2);
act_periRetreat_Z_mean=mean(act_periRetreat_Z );
act_periRetreat_Z_sem=std(act_periRetreat_Z )/sqrt(numtrial);
times=-3:0.05:3.99;

figure
plot(times,act_periRetreat_Z_mean,'k');
y1=act_periRetreat_Z_mean+act_periRetreat_Z_sem;
y2=act_periRetreat_Z_mean-act_periRetreat_Z_sem;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'r','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,act_periRetreat_Z_mean,'r');

hold on

% Plot sign_Inb psth
inb_periRetreat_Z =zeros(1,160);

for ii= 1:size(idx_inb,2)
    inb_periRetreat_Z  =cat(1,inb_periRetreat_Z ,PYR(idx_inb(ii)).periRetreat_Z );
end

[m,n]=find(isnan(inb_periRetreat_Z )==1);
inb_periRetreat_Z (m,:)=[];

inb_periRetreat_Z =inb_periRetreat_Z (:,1:140);
numtrial=size(PYR,2);
inb_periRetreat_Z_mean=mean(inb_periRetreat_Z );
inb_periRetreat_Z_sem=std(inb_periRetreat_Z )/sqrt(numtrial);
times=-3:0.05:3.99;

plot(times,inb_periRetreat_Z_mean,'k')
y1=inb_periRetreat_Z_mean+inb_periRetreat_Z_sem;
y2=inb_periRetreat_Z_mean-inb_periRetreat_Z_sem;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'b','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,inb_periRetreat_Z_mean,'b');

ylim([-0.6,1.8]);
