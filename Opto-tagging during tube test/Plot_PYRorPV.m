clc; clear;
close all

%% load 1) result from PV_tagging_PETH.m, 2) wf_prop_batchProcess
folderAddress='G:\ZCY-2021-rebuttal data\0701-Tagging analysis';
load([folderAddress,'\Output new\Total-ttdata.mat']);
load([folderAddress,'\Output new\Total-TagData.mat'])

tagFn=size(OptoTag,2);
recFn=size(ttdata,2);
if ~tagFn==recFn %% check for the numbers of data files
    disp('File numbers processed for PETH and Optotagging are not the same.')
else
end
countPV=0;
idx1=1;
recFidx=zeros(tagFn,1);
for ff=1:tagFn
    for rr=1:recFn
        if contains(ttdata(rr).recName, OptoTag(ff).file)
            recFidx(ff)=rr;
        else
        end
    end
end

for ff=1:tagFn
    unitNum=size(OptoTag(ff).unit,2);
    for ii=1:unitNum
        if (strcmp(OptoTag(ff).unit(ii).classification, 'pPV') + strcmp(OptoTag(ff).unit(ii).classification, 'pFSI'))
            PV(idx1).file=OptoTag(ff).file;
            PV(idx1).unit=OptoTag(ff).unit(ii).name;
            PV(idx1).classification=OptoTag(ff).unit(ii).classification;
            PV(idx1).fr=OptoTag(ff).unit(ii).fr;
            PV(idx1).pt_ratio=OptoTag(ff).unit(ii).pt_ratio;
            PV(idx1).pt_width=OptoTag(ff).unit(ii).pt_width;
            PV(idx1).accuracy=OptoTag(ff).unit(ii).accuracy;
            PV(idx1).jitter=OptoTag(ff).unit(ii).jitter;
            PV(idx1).wf_mean=OptoTag(ff).unit(ii).wf_mean;
            if recFidx(ff)
                for jjj=1:size(ttdata(recFidx(ff)).unit,2)
                    if contains(ttdata(recFidx(ff)).unit(jjj).name, PV(idx1).unit)
                        countPV=countPV+1;
                        PV(idx1).PushBout=ttdata(recFidx(ff)).unit(jjj).PushBout;
                        PV(idx1).periPush=ttdata(recFidx(ff)).unit(jjj).periPush;
                        PV(idx1).pushT=ttdata(recFidx(ff)).pushT;
                        PV(idx1).RetreatBout=ttdata(recFidx(ff)).unit(jjj).RetreatBout;
                        PV(idx1).periRetreat=ttdata(recFidx(ff)).unit(jjj).periRetreat;
                        PV(idx1).retreatT=ttdata(recFidx(ff)).retreatT;
                        if ~isempty(ttdata(recFidx(ff)).stillT)               %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            PV(idx1).StillBout=ttdata(recFidx(ff)).unit(jjj).StillBout;
                            PV(idx1).periStill=ttdata(recFidx(ff)).unit(jjj).periStill;
                            
                            PV(idx1).stillT=ttdata(recFidx(ff)).stillT;
                        else              %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        end               %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                    else
                    end
                end
            else
            end
            idx1=idx1+1;
        end
        
    end
end

%% peri-event plot for firing rate
PreT=3;
PostT=5;
Bin=0.05;
baselineTime=[-3 -1];
range=[-PreT PostT];
PlotT=[range(1)+Bin:Bin:range(2)];

calcPre=[-3 -1];
calcPost=[-0.5 0.5];

plotB=ceil(sqrt(countPV));
plotA=ceil(countPV/plotB);

fig1=figure
for ppp=1:size(PV,2)
    
    PushN=size(PV(ppp).periPush,1);
    avePush=mean(PV(ppp).periPush);
    semPush=std(PV(ppp).periPush)/sqrt(PushN);
    RetreatN=size(PV(ppp).periRetreat,1);
    aveRetreat=mean(PV(ppp).periRetreat,1);
    semRetreat=std(PV(ppp).periRetreat)/sqrt(RetreatN);
    
    subplot(plotA, plotB, ppp)
    if ~isempty(PV(ppp).periStill)              %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        StillN=size(PV(ppp).periStill,1);
        aveStill=mean(PV(ppp).periStill,1);
        semStill=std(PV(ppp).periStill)/sqrt(StillN);
        sem1=fill([PlotT,fliplr(PlotT)],[aveStill-semStill,fliplr(aveStill+semStill)],'k','facealpha',0.3, 'LineStyle','none');
        hold on
    else                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if aveRetreat            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sem2=fill([PlotT,fliplr(PlotT)],[aveRetreat-semRetreat,fliplr(aveRetreat+semRetreat)],'b','facealpha',0.3, 'LineStyle','none');
        hold on
        plot(PlotT,aveRetreat,'b');
        hold on
    else           %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end             %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isnan(avePush)
        sem3=fill([PlotT,fliplr(PlotT)],[avePush-semPush,fliplr(avePush+semPush)],'r','facealpha',0.3, 'LineStyle','none');
        hold on
    else
    end
    if ~isempty(PV(ppp).periStill)              %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        plot(PlotT,aveStill,'k');
        hold on
        plot(PlotT,avePush,'r');
    else                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    xlim(range);
    xlabel('Time from onset (s)');
    ylabel('Firing rate');
    title ([PV(ppp).file,'-',PV(ppp).unit,' ',PV(ppp).classification]);
    
    
end
figfolder=[folderAddress,'\Output new\'];
if exist(figfolder)==0
    mkdir(figfolder);
end
savefig([figfolder,'\v2-PETH for each PV unit.fig']);
saveas(fig1,[figfolder,'\v2-PETH for each PV unit.png'],'png');

%% calculate for Z-score
bas=(baselineTime+PreT)/Bin;
basIdx=[bas(1)+1:bas(2)];
% freqThreshold=1;

fig2=figure
for pppp=1:size(PV,2)
    PVstat(pppp).file=PV(pppp).file;
    PVstat(pppp).unit=PV(pppp).unit;
    if ~isempty(PV(pppp).periPush)
        push=PV(pppp).periPush;
        push_duration=PV(pppp).pushT(:,3);
        pushN=size(push,1);
        push_bas_ave=mean(push(:,basIdx),2);
        push_bas_std=std(push(:,basIdx),1,2);
        
        for kk=1:pushN
            push_Zscore(kk,:)=smooth((push(kk,:)-push_bas_ave(kk))/push_bas_std(kk), 2);
            inPush(kk,1)=mean(push(kk, (PreT/Bin+1):round((min(push_duration(kk),PostT)+PreT)/Bin)));
            inPush_Z(kk,1)=mean(push_Zscore(kk, (PreT/Bin+1):round((min(push_duration(kk),PostT)+PreT)/Bin)));
        end
        
        push_pre=mean(push (:, (PreT+calcPre(1))/Bin+1 : (PreT+calcPre(2))/Bin), 2);
        push_post=mean(push (:, (PreT+calcPost(1))/Bin+1 : (PreT+calcPost(2))/Bin), 2);
        
        [p1, h1]=ranksum(push_pre, push_post);
        PVstat(pppp).push_P1=p1;
        PVstat(pppp).push_H1=h1;
        PVstat(pppp).push_CI1=mean((push_post-push_pre)./(push_post+push_pre),'omitnan');
        [p2, h2]=signrank(push_pre, inPush);
        PVstat(pppp).push_P2=p2;
        PVstat(pppp).push_H2=h2;
        PVstat(pppp).push_CI2=mean((inPush-push_pre)./(inPush+push_pre),'omitnan');
        
        PV(pppp).periPush_Z=push_Zscore;
        push_pre_Z=mean(push_Zscore (:, (PreT+calcPre(1))/Bin+1 : (PreT+calcPre(2))/Bin), 2);
        push_post_Z=mean(push_Zscore (:, (PreT+calcPost(1))/Bin+1 : (PreT+calcPost(2))/Bin), 2);
        
        if sum(~isnan(push_pre_Z))
            [pZ1, hZ1]=signrank(push_pre_Z, push_post_Z);
            PVstat(pppp).Z_push_P1=pZ1;
            PVstat(pppp).Z_push_H1=hZ1;
            PVstat(pppp).Z_push_change1=mean(push_post_Z-push_pre_Z, 'omitnan');
            [pZ2, hZ2]=signrank(push_pre_Z, inPush_Z);
            PVstat(pppp).Z_push_P2=pZ2;
            PVstat(pppp).Z_push_H2=hZ2;
            PVstat(pppp).Z_push_change2=mean(inPush_Z-push_pre_Z, 'omitnan');
            aveZPush=mean(push_Zscore,1,'omitnan');
            semZPush=std(push_Zscore,'omitnan')/sqrt(pushN);
        else
        end
    else
    end
    if ~isempty(PV(pppp).periRetreat)
        retreat=PV(pppp).periRetreat;
        retreat_duration=PV(pppp).retreatT(:,3);
        retreatN=size(retreat,1);
        retreat_bas_ave=mean(retreat(:,basIdx),2);
        retreat_bas_std=std(retreat(:,basIdx),1,2);
        for kk=1:retreatN
            retreat_Zscore(kk,:)=smooth((retreat(kk,:)-retreat_bas_ave(kk))/retreat_bas_std(kk), 2);
            inRetreat(kk,1)=mean(retreat(kk,(PreT/Bin+1):round(min(retreat_duration(kk),PostT)+PreT)/Bin));
            inRetreat_Z(kk,1)=mean(retreat_Zscore(kk,PreT/Bin+1:round(min(retreat_duration(kk),PostT)+PreT)/Bin));
        end
        
        retreat_pre=mean(retreat (:,(PreT+calcPre(1))/Bin+1 : (PreT+calcPre(2))/Bin),2);
        retreat_post=mean(retreat(:,(PreT+calcPost(1))/Bin+1 : (PreT+calcPost(2))/Bin),2);
        
        [Rp1, Rh1]=ranksum(retreat_pre, retreat_post);
        PVstat(pppp).retreat_P1=Rp1;
        PVstat(pppp).retreat_H1=Rh1;
        PVstat(pppp).retreat_CI1=mean((retreat_post-retreat_pre)./(retreat_post+retreat_pre),'omitnan');
        [Rp2, Rh2]=ranksum(retreat_pre, inRetreat);
        PVstat(pppp).retreat_P2=Rp2;
        PVstat(pppp).retreat_H2=Rh2;
        PVstat(pppp).retreat_CI2=mean((inRetreat-retreat_pre)./(inRetreat+retreat_pre),'omitnan');
        
        retreat_preZ=mean(retreat_Zscore (:,(PreT+calcPre(1))/Bin+1 : (PreT+calcPre(2))/Bin),2);
        retreat_postZ=mean(retreat_Zscore(:,(PreT+calcPost(1))/Bin+1 : (PreT+calcPost(2))/Bin),2);
        
        PV(pppp).periRetreat_Z=retreat_Zscore;
        if sum(~isnan(retreat_preZ))
            [RpZ1, RhZ1]=signrank(retreat_preZ, retreat_postZ);
            PVstat(pppp).Z_retreat_P1=RpZ1;
            PVstat(pppp).Z_retreat_H1=RhZ1;
            PVstat(pppp).Z_retreat_change1=mean(retreat_postZ-retreat_preZ, 'omitnan');
            [RpZ2, RhZ2]=signrank(retreat_preZ, inRetreat_Z);
            PVstat(pppp).Z_retreat_P2=RpZ2;
            PVstat(pppp).Z_retreat_H2=RhZ2;
            PVstat(pppp).Z_retreat_change2=mean(inRetreat_Z-retreat_preZ, 'omitnan');
            aveZRetreat=mean(retreat_Zscore,1,'omitnan');
            semZRetreat=std(retreat_Zscore,'omitnan')/sqrt(retreatN);
        else
        end
    else
    end
    
    if ~isempty(PV(pppp).periStill)              %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        still=PV(pppp).periStill;
        still_duration=PV(pppp).stillT(:,3);
        stillN=size(still,1);
        for kk=1:stillN
            inStill(kk,1)=mean(still(kk, (PreT/Bin+1):round((min(still_duration(kk),PostT)+PreT)/Bin)));
        end
        
        [SP_p, SP_h]=ranksum(inStill, inPush);
        PVstat(pppp).push_still_P=SP_p;
        PVstat(pppp).push_still_H=SP_h;
        PVstat(pppp).push_still_CI=(mean(inPush, 'omitnan')-mean(inStill, 'omitnan'))/(mean(inPush, 'omitnan')+mean(inStill, 'omitnan'));
        [SR_p, SR_h]=ranksum(inStill, inRetreat);
        PVstat(pppp).retreat_still_P=SR_p;
        PVstat(pppp).retreat_still_H=SR_h;
        PVstat(pppp).retreat_still_CI=(mean(inRetreat, 'omitnan')-mean(inStill, 'omitnan'))/(mean(inRetreat, 'omitnan')+mean(inStill, 'omitnan'));
    else             %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end             %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    subplot(plotA, plotB, pppp)
    %     for ii=1:retreatN
    %         plot(PlotT,retreat_Zscore(ii,:),'Color',[0.1 0.6 1], 'LineWidth', 0.1) ; hold on
    %     end
    %     for jj=1:retreatN
    %         plot(PlotT,retreat_Zscore(jj,:),'Color',[1 0.6 0.6], 'LineWidth', 0.1) ; hold on
    %     end
    if aveZRetreat
        sem1=fill([PlotT,fliplr(PlotT)],[aveZRetreat-semZRetreat,fliplr(aveZRetreat+semZRetreat)],'b','facealpha',0.3, 'LineStyle','none');
        hold on
        plot(PlotT,aveZRetreat,'b');
        hold on
    else
    end
    if aveZPush
        sem2=fill([PlotT,fliplr(PlotT)],[aveZPush-semZPush,fliplr(aveZPush+semZPush)],'r','facealpha',0.3, 'LineStyle','none');
        hold on
        plot(PlotT,aveZPush,'r');
        xlim(range);
    else
    end
    
    
    xlabel('Time from onset (s)');
    ylabel('Z-score');
    
    title ([PV(pppp).file,'-',PV(pppp).unit,' ',PV(pppp).classification]);
    clearvars push push_duration push_Zscore retreat_Zscore retreat retreat_duration  still
    clearvars push_pre push_post inPush retreat_pre retreat_post inRetreat push_duration retreat_duration inStill still_duration
    clearvars push_preZ push_postZ inPush_Z retreat_preZ retreat_postZ inRetreat_Z
end
figfolder=[folderAddress,'\Output new\'];
if exist(figfolder)==0
    mkdir(figfolder);
end
savefig([figfolder,'v2-PETH for each PV unit_Zscore.fig']);
saveas(fig2,[figfolder,'v2-PETH for each PV unit_Zscore.png'],'png');

%% extract stat information into multiple arrays
for tt=1:size(PVstat,2)
    if ~isempty(PVstat(tt).push_P1) & ~isnan(PVstat(tt).push_P1)
        push_P1(tt)=PVstat(tt).push_P1;
        push_H1(tt)=PVstat(tt).push_H1;
        push_CI1(tt)=PVstat(tt).push_CI1;
        push_P2(tt)=PVstat(tt).push_P2;
        push_H2(tt)=PVstat(tt).push_H2;
        push_CI2(tt)=PVstat(tt).push_CI2;
        Z_push_P1(tt)=PVstat(tt).Z_push_P1;
        Z_push_H1(tt)=PVstat(tt).Z_push_H1;
        Z_push_CI1(tt)=PVstat(tt).Z_push_change1;
        Z_push_P2(tt)=PVstat(tt).Z_push_P2;
        Z_push_H2(tt)=PVstat(tt).Z_push_H2;
        Z_push_CI2(tt)=PVstat(tt).Z_push_change2;
        
        retreat_P1(tt)=PVstat(tt).retreat_P1;
        retreat_H1(tt)=PVstat(tt).retreat_H1;
        retreat_CI1(tt)=PVstat(tt).retreat_CI1;
        retreat_P2(tt)=PVstat(tt).retreat_P2;
        retreat_H2(tt)=PVstat(tt).retreat_H2;
        retreat_CI2(tt)=PVstat(tt).retreat_CI2;
        Z_retreat_P1(tt)=PVstat(tt).Z_retreat_P1;
        Z_retreat_H1(tt)=PVstat(tt).Z_retreat_H1;
        Z_retreat_CI1(tt)=PVstat(tt).Z_retreat_change1;
        Z_retreat_P2(tt)=PVstat(tt).Z_retreat_P2;
        Z_retreat_H2(tt)=PVstat(tt).Z_retreat_H2;
        Z_retreat_CI2(tt)=PVstat(tt).Z_retreat_change2;
    else
    end
    
    if ~isempty(PVstat(tt).push_still_P)              %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        push_still_P(tt)=PVstat(tt).push_still_P;
        push_still_H(tt)=PVstat(tt).push_still_H;
        push_still_CI(tt)=PVstat(tt).push_still_CI;
        retreat_still_P(tt)=PVstat(tt).retreat_still_P;
        retreat_still_H(tt)=PVstat(tt).retreat_still_H;
        retreat_still_CI(tt)=PVstat(tt).retreat_still_CI;
    else                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%% classification of PV untis dependent on their responses to push/retreat:
% classification1: increase in Push/ increase in Retreat
% classification2: increase in Push/ decrease in Retreat
% classification3: increase in Push/ no change in Retreat
% classification4: decrease in Push/ increase in Retreat
% classification5: decrease in Push/ decrease in Retreat
% classification6: decrease in Push/ no change in Retreat
% classification7: no change in Push/ increase in Retreat
% classification8: no change in Push/ decrease in Retreat
% classification9: no change in Push/ no change in Retreat
statclass(:,1)= ClassChange(size(PV,2), push_H1, push_CI1, retreat_H1, retreat_CI1);
statclass(:,2)= ClassChange(size(PV,2), push_H2, push_CI2, retreat_H2, retreat_CI2);
statclass(:,3)= ClassChange(size(PV,2), Z_push_H1, Z_push_CI1, Z_retreat_H1, Z_retreat_CI1);
statclass(:,4)= ClassChange(size(PV,2), Z_push_H2, Z_push_CI2, Z_retreat_H2, Z_retreat_CI2);
statclass(:,5)= ClassChange(size(PV,2), push_still_H, push_still_CI, retreat_still_H, retreat_still_CI);

for stat=1:5
    for ccc=1:9
        loc= find(statclass(:,stat) == ccc);
        PVclassification(stat).stat(ccc).file={PVstat(loc).file};
        PVclassification(stat).stat(ccc).unit={PVstat(loc).unit};
        PVclassification(stat).stat(ccc).index=loc;
        PVclassification(stat).stat(ccc).number=length(loc);
    end
end

%% plot for PV units, classification1, which increases firing in both push and retreat
%stat1, plot with firing rate
fig3=figure
PVDualIncN=PVclassification(1).stat(1).number;
PVDualInc_file1=PVclassification(1).stat(1).file;
PVDualInc_unit1=PVclassification(1).stat(1).unit;
PVDualInc_loc1=PVclassification(1).stat(1).index;
plotB2=ceil(sqrt(PVDualIncN));
plotA2=ceil(PVDualIncN/plotB2);
for aaa=1:PVDualIncN
    PushN=size(PV(PVDualInc_loc1(aaa)).periPush,1);
    avePush=mean(PV(PVDualInc_loc1(aaa)).periPush);
    semPush=std(PV(PVDualInc_loc1(aaa)).periPush)/sqrt(PushN);
    RetreatN=size(PV(PVDualInc_loc1(aaa)).periRetreat,1);
    aveRetreat=mean(PV(PVDualInc_loc1(aaa)).periRetreat,1);
    semRetreat=std(PV(PVDualInc_loc1(aaa)).periRetreat)/sqrt(RetreatN);
    
    subplot(plotA2, plotB2, aaa)
    sem1=fill([PlotT,fliplr(PlotT)],[aveRetreat-semRetreat,fliplr(aveRetreat+semRetreat)],'b','facealpha',0.3, 'LineStyle','none');
    hold on
    sem2=fill([PlotT,fliplr(PlotT)],[avePush-semPush,fliplr(avePush+semPush)],'r','facealpha',0.3, 'LineStyle','none');
    hold on
    plot(PlotT,aveRetreat,'b');
    hold on
    plot(PlotT,avePush,'r');
    xlim(range);
    xlabel('Time from onset (s)');
    ylabel('Firing rate');
    title ([PV(PVDualInc_loc1(aaa)).file,'-',PV(PVDualInc_loc1(aaa)).unit,' ',PV(PVDualInc_loc1(aaa)).classification]);
    clearvars avePush semPush aveRetreat semRetreat
end


%% plot for PV units, classification1, which increases firing in both push and retreat
%stat4, plot with Zscore
fig4=figure
PVDualIncN=PVclassification(4).stat(1).number;
PVDualInc_file2=PVclassification(4).stat(1).file;
PVDualInc_unit2=PVclassification(4).stat(1).unit;
PVDualInc_loc2=PVclassification(4).stat(1).index;
plotB2=ceil(sqrt(PVDualIncN));
plotA2=ceil(PVDualIncN/plotB2);
for pppp=1:PVDualIncN
    
    push=PV(PVDualInc_loc2(pppp)).periPush;
    push_duration=PV(PVDualInc_loc2(pppp)).pushT(:,3);
    pushN=size(push,1);
    push_bas_ave=mean(push(:,basIdx),2);
    push_bas_std=std(push(:,basIdx),1,2);
    for kk=1:pushN
        push_Zscore(kk,:)=smooth((push(kk,:)-push_bas_ave(kk))/push_bas_std(kk), 2);
        inPush(kk,1)=mean(push(kk, (PreT/Bin+1):round((min(push_duration(kk),PostT)+PreT)/Bin)));
        inPush_Z(kk,1)=mean(push_Zscore(kk, (PreT/Bin+1):round((min(push_duration(kk),PostT)+PreT)/Bin)));
    end
    
    retreat=PV(PVDualInc_loc2(pppp)).periRetreat;
    retreat_duration=PV(PVDualInc_loc2(pppp)).retreatT(:,3);
    retreatN=size(retreat,1);
    retreat_bas_ave=mean(retreat(:,basIdx),2);
    retreat_bas_std=std(retreat(:,basIdx),1,2);
    for kk=1:retreatN
        retreat_Zscore(kk,:)=smooth((retreat(kk,:)-retreat_bas_ave(kk))/retreat_bas_std(kk), 2);
        inRetreat(kk,1)=mean(retreat(kk,(PreT/Bin+1):round(min(retreat_duration(kk),PostT)+PreT)/Bin));
        inRetreat_Z(kk,1)=mean(retreat_Zscore(kk,PreT/Bin+1:round(min(retreat_duration(kk),PostT)+PreT)/Bin));
    end
    
    aveZPush=mean(push_Zscore,1,'omitnan');
    semZPush=std(push_Zscore,'omitnan')/sqrt(pushN);
    
    aveZRetreat=mean(retreat_Zscore,1,'omitnan');
    semZRetreat=std(retreat_Zscore,'omitnan')/sqrt(retreatN);
    
    subplot(plotA2, plotB2, pppp)
    %     for ii=1:retreatN
    %         plot(PlotT,retreat_Zscore(ii,:),'Color',[0.1 0.6 1], 'LineWidth', 0.1) ; hold on
    %     end
    %     for jj=1:retreatN
    %         plot(PlotT,retreat_Zscore(jj,:),'Color',[1 0.6 0.6], 'LineWidth', 0.1) ; hold on
    %     end
    sem1=fill([PlotT,fliplr(PlotT)],[aveZRetreat-semZRetreat,fliplr(aveZRetreat+semZRetreat)],'b','facealpha',0.3, 'LineStyle','none');
    hold on
    sem2=fill([PlotT,fliplr(PlotT)],[aveZPush-semZPush,fliplr(aveZPush+semZPush)],'r','facealpha',0.3, 'LineStyle','none');
    hold on
    plot(PlotT,aveZRetreat,'b');
    hold on
    plot(PlotT,aveZPush,'r');
    xlim(range);
    xlabel('Time from onset (s)');
    ylabel('Z-score');
    
    title ([PV(PVDualInc_loc2(pppp)).file,'-',PV(PVDualInc_loc2(pppp)).unit, ' ', PV(PVDualInc_loc2(pppp)).classification]);
    clearvars push push_duration push_Zscore retreat_Zscore retreat retreat_duration
    clearvars push_pre push_post inPush retreat_pre retreat_post inRetreat push_duration retreat_duration
    clearvars push_preZ push_postZ inPush_Z retreat_preZ retreat_postZ inRetreat_Z
end
figfolder=[folderAddress,'\Output new\'];
if exist(figfolder)==0
    mkdir(figfolder);
end
savefig([figfolder,'PETH for each PV unit increase in both push and retreat_Zscore.fig']);
saveas(fig4,[figfolder,'PETH for each PV unit increase in both push and retreat_Zscore.png'],'png');

%%
fig5=figure   %% scatter plot
color=['y', 'y', 'r', 'y', 'y', 'r', 'g', 'g', 'k'];
alpha=[1, 1, 0.5, 1, 1, 0.5, 0.5, 0.5, 0.25];

subplot(2,2,1)  %% retreat vs. push, firing rate, ranksum pre vs. post
for cc=1:9
    idx=PVclassification(1).stat(cc).index;
    if ~isempty(idx)
        scatter(retreat_CI1(idx), push_CI1(idx), color(cc),'filled', 'MarkerEdgeColor','none', 'MarkerFaceAlpha', alpha(cc)); hold on;
    else
    end
    clearvars idx
end
xlim auto; x=xlim;
ylim auto; y=ylim;
plot(x,[0 0], '--k');
plot([0 0],y, '--k');

xlabel('Retreat change index');
ylabel('Push change index');
title('pre-post FR')
clearvars pushInc pushDec retreatInc retreatDec

subplot(2,2,2) %% retreat vs. push, firing rate, ranksum pre vs. during
for cc=1:9
    idx=PVclassification(2).stat(cc).index;
    if ~isempty(idx)
        scatter(retreat_CI2(idx), push_CI2(idx), color(cc),'filled', 'MarkerEdgeColor','none', 'MarkerFaceAlpha', alpha(cc)); hold on;
    else
    end
    clearvars idx
end
xlim auto; x=xlim;
ylim auto; y=ylim;
plot(x,[0 0], '--k');
plot([0 0],y, '--k');

xlabel('Retreat change index');
ylabel('Push change index');
title('pre-during FR')
clearvars pushInc pushDec retreatInc retreatDec

subplot(2,2,3) %% retreat vs. push, Zscored, signrank pre vs. post
for cc=1:9
    idx=PVclassification(3).stat(cc).index;
    if ~isempty(idx)
        scatter(Z_retreat_CI1(idx), Z_push_CI1(idx), color(cc),'filled', 'MarkerEdgeColor','none', 'MarkerFaceAlpha', alpha(cc)); hold on;
    else
    end
    clearvars idx
end
xlim auto; x=xlim;
ylim auto; y=ylim;
plot(x,[0 0], '--k');
plot([0 0],y, '--k');

xlabel('Retreat Zscore change');
ylabel('Push Zscore change');
title('pre-post Zscore')
clearvars pushInc pushDec retreatInc retreatDec

subplot(2,2,4) %% retreat vs. push, Zscored, signrank pre vs. post
for cc=1:9
    idx=PVclassification(4).stat(cc).index;
    if ~isempty(idx)
        scatter(Z_retreat_CI2(idx), Z_push_CI2(idx), color(cc),'filled', 'MarkerEdgeColor','none', 'MarkerFaceAlpha', alpha(cc)); hold on;
    else
    end
    clearvars idx
end
xlim auto; x=xlim;
ylim auto; y=ylim;
plot(x,[0 0], '--k');
plot([0 0],y, '--k');

xlabel('Retreat Zscore change');
ylabel('Push Zscore change');
title('pre-during Zscore')
clearvars pushInc pushDec retreatInc retreatDec

savefig([figfolder,'v2-push vs retreat.fig']);
saveas(fig5,[figfolder,'v2-push vs retreat.png'],'png');
sig_unit_N=[sum(push_H1), sum(retreat_H1);
    sum(push_H2), sum(retreat_H2);
    sum(Z_push_H1), sum(Z_retreat_H1);
    sum(Z_push_H2), sum(Z_retreat_H2);]



save([folderAddress,'\Output new\v2-PV_PETH.mat'],'PV');
save([folderAddress,'\Output new\v2-PVstat.mat'],'PVstat');
save([folderAddress,'\Output new\v2-PVclass.mat'],'PVclassification');