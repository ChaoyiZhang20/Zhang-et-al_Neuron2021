clc; clear; 
close all;
%% set parameters for plotting
Bin=0.05;
SmoothN=5;
PreT=3;
PostT=5;
range=[-PreT PostT];
PlotT=[range(1)+Bin:Bin:range(2)];
Threshold=[0 0 0]; %% threshold to process behavioral bouts, time in seconds
% 1) combine adjacent (interval<Threshold(1)) and the same kind of behaviors into one
% bout
% 2) exclude bouts with short duration (duration<Threshold(2))
% 3) exclude bouts that other behaviors happen in pre-zero baseline [Threshold(3) 0]
%% Options for figure plotting
PlotRaster=0;  %% set PlotRaster=1 will plot raster around push or retreat for each unit and rec file.
% Zscore??

%% folder address for the stored data
% each subfolder contains one .mat file record spk data, and named with
% mouse+date inforation, eg. C-2105081
% and one .mat file for event information, name should contain 'event'
folderAddress='H:\0701-Tagging analysis';
foldername=dir([folderAddress,'\Total Input\tube test\']);
folderNum=size(foldername,1)-2;

for ff=1:folderNum
    % load data
    RecFileName=dir([folderAddress,'\Total Input\tube test\',foldername(ff+2).name]);
    if ~size(RecFileName,1)==4
        warning(['Check files in ',foldername(ff+2).name]);
    end
    if contains(RecFileName(3).name,'event') %% recognize event file by the name
        event=load([folderAddress,'\Total Input\tube test\',foldername(ff+2).name,'\',RecFileName(3).name]);
        spkData=load([folderAddress,'\Total Input\tube test\',foldername(ff+2).name,'\',RecFileName(4).name]);
    else
        event=load([folderAddress,'\Total Input\tube test\',foldername(ff+2).name,'\',RecFileName(4).name]);
        spkData=load([folderAddress,'\Total Input\tube test\',foldername(ff+2).name,'\',RecFileName(3).name]);
    end
    
    
    ttdata(ff).recName=foldername(ff+2).name;
     
    %% decide whether times for ephys and event data are aligned, and do
    % align time if not
    % recording start time stamp will be removed after this step
    spkStartN=length(spkData.EVT20);
    behavior=event.Behavior;
    eventSidx=find(strcmp(behavior, 'recording start'));
    if ~isempty(eventSidx)
        minN=min(spkStartN,length(eventSidx));
        difTime=event.Time(1:minN)-spkData.EVT20(1:minN);
        if abs(sum(difTime))>1  %% decide whether time in event-%%.mat file has been alighed or not
            behaviorTime=event.Time-mean(difTime); %% behaviorTime is aligned to ephys rec file
        else
            behaviorTime=event.Time;
        end
        ttdata(ff).behaviorTime=behaviorTime(eventSidx(end)+1:end);
        ttdata(ff).behavior(:,1)=event.Behavior(eventSidx(end)+1:end);
        ttdata(ff).behavior(:,2)=event.Status(eventSidx(end)+1:end);
    else
        ttdata(ff).behaviorTime=event.Time;
        ttdata(ff).behavior(:,1)=event.Behavior;
        ttdata(ff).behavior(:,2)=event.Status;
    end
        
%    clearvars spkStartN minN behavior eventSidx behaviorTime difTime 
    %% pushT and retreatT calculation, store as [:,(start, stop, duration)]
    [pushT,retreatT, stillT]=Events_2(ttdata(ff).behavior, ttdata(ff).behaviorTime, Threshold);
    ttdata(ff).pushT=pushT;
    ttdata(ff).retreatT=retreatT;
    ttdata(ff).stillT=stillT;
    
    %% process for unit spk data
    fieldname=fieldnames(spkData);
    loc=contains(fieldname,'_ts');   
    locIndex=find(loc);
    UnitNum=sum(loc);
    PushN=size(ttdata(ff).pushT,1);
    RetreatN=size(ttdata(ff).retreatT,1);
    StillN=size(ttdata(ff).stillT,1);
    
    for jj=1:UnitNum
        unitname=fieldname{locIndex(jj)};
        name_str = strsplit(unitname,'_'); 
        ttdata(ff).unit(jj).name=name_str{1,2};
        ttdata(ff).unit(jj).spk=getfield(spkData,string(fieldname(locIndex(jj))));
        spktempt=ttdata(ff).unit(jj).spk;
        ttdata(ff).unit(jj).aveFR=length(spktempt)/(spkData.Stop- spkData.Start);  %%average firing rate during the whole recording
        for kkk=1:PushN
            tempt1=spktempt(spktempt>ttdata(ff).pushT(kkk,1)-PreT & spktempt <= ttdata(ff).pushT(kkk,1)+PostT);
            if ~isempty(tempt1)
                tempt1=tempt1-ttdata(ff).pushT(kkk,1);
            else
            end
            ttdata(ff).unit(jj).PushBout{kkk}=tempt1; 
            clearvars tempt1;
        end
        
        for kkkk=1:RetreatN
            tempt2=spktempt(spktempt>ttdata(ff).retreatT(kkkk,1)-PreT & spktempt <= ttdata(ff).retreatT(kkkk,1)+PostT);
            if ~isempty(tempt2)
                tempt2=tempt2-ttdata(ff).retreatT(kkkk,1);
            else
            end
            ttdata(ff).unit(jj).RetreatBout{kkkk}=tempt2;
            clearvars tempt2;
        end
        
        for kkkkk=1:StillN
            tempt3=spktempt(spktempt>ttdata(ff).stillT(kkkkk,1)-PreT & spktempt <= ttdata(ff).stillT(kkkkk,1)+PostT);
            if ~isempty(tempt3)
                tempt3=tempt3-ttdata(ff).stillT(kkkkk,1);
            else
            end
            ttdata(ff).unit(jj).StillBout{kkkkk}=tempt3;
            clearvars tempt3;
        end
        
    end
        
        
     %% raster plot for each unit, figures will be saved in root\DATA_output   
        if PlotRaster==1
            for aa=1:size(ttdata(ff).unit,2)   %% unit number
                h=figure
                subplot(2,1,1)
                for bbb=1:size(ttdata(ff).unit(aa).PushBout,2)  %% push bouts
                    boutDuration=ttdata(ff).pushT(bbb,3);
                    fillx=[0,0,min(boutDuration,PostT),min(boutDuration,PostT)];
                    filly=[bbb,bbb-1,bbb-1,bbb];
                    fill(fillx, filly, 'k', 'facealpha',0.2,'edgealpha',0);

                    if ~isempty(ttdata(ff).unit(aa).PushBout{bbb})
                        for ccc=1:length(ttdata(ff).unit(aa).PushBout{bbb})
                            x=ttdata(ff).unit(aa).PushBout{bbb}(ccc);
                            line([x,x],[bbb-1,bbb]); hold on;
                        end
                    else
                    end     
                end
                ylim([0 bbb]);
                xlabel('Time from onset (s)');
                ylabel('Trials');
                title([ttdata(ff).recName,'_',ttdata(ff).unit(aa).name,'_push']);
                
                subplot(2,1,2)
                for bbbb=1:size(ttdata(ff).unit(aa).RetreatBout,2)  %% retreat bouts
                    boutDuration=ttdata(ff).retreatT(bbbb,3);
                    fillx=[0,0,min(boutDuration,PostT),min(boutDuration,PostT)];
                    filly=[bbbb,bbbb-1,bbbb-1,bbbb];
                    fill(fillx, filly, 'k', 'facealpha',0.2,'edgealpha',0); 
                    
                    if ~isempty(ttdata(ff).unit(aa).RetreatBout{bbbb})
                        for ccc=1:length(ttdata(ff).unit(aa).RetreatBout{bbbb})
                            x=ttdata(ff).unit(aa).RetreatBout{bbbb}(ccc);
                            line([x,x],[bbbb-1,bbbb]); hold on;
                        end
                    else
                    end   
                end
                ylim([0 bbbb]);
                xlabel('Time from onset (s)');
                ylabel('Trials');
                title([ttdata(ff).recName,'_',ttdata(ff).unit(aa).name,'_retreat']);
                
                figfolder=[folderAddress,'\Output new\Raster by files\',ttdata(ff).recName,];
                if exist(figfolder)==0
                    mkdir(figfolder);
                end
                
                savefig([figfolder,'\v1-',ttdata(ff).unit(aa).name,'.fig']);
                saveas(h,[figfolder,'\v1-',[ttdata(ff).unit(aa).name,'.png']],'png');
                close
            end
        else
        end
        
        %% peri-event plot for firing rate
        p=figure
        plotB=ceil(sqrt(UnitNum));
        plotA=ceil(UnitNum/plotB);

        for jj=1:UnitNum
            for nnn=1:PushN
                pethPush(nnn,:)=Freq(ttdata(ff).unit(jj).PushBout{1,nnn}, range, Bin, SmoothN);
            end
            ttdata(ff).unit(jj).periPush=pethPush;
            avePush=mean(pethPush);
            semPush=std(pethPush)/sqrt(PushN);
            for mmm=1:RetreatN
                pethRetreat(mmm,:)=Freq(ttdata(ff).unit(jj).RetreatBout{1,mmm}, range, Bin, SmoothN);
            end
            ttdata(ff).unit(jj).periRetreat=pethRetreat;
            aveRetreat=mean(pethRetreat);
            semRetreat=std(pethRetreat)/sqrt(RetreatN);
            
            if StillN           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for lll=1:StillN
                    pethStill(lll,:)=Freq(ttdata(ff).unit(jj).StillBout{1,lll}, range, Bin, SmoothN);
                end
                ttdata(ff).unit(jj).periStill=pethStill;
                aveStill=mean(pethStill);
                semStill=std(pethStill)/sqrt(StillN);
            else               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            subplot(plotA, plotB, jj)
            if StillN
                sem1=fill([PlotT,fliplr(PlotT)],[aveStill-semStill,fliplr(aveStill+semStill)],'k','facealpha',0.3, 'LineStyle','none');
                hold on
            else
            end
            sem2=fill([PlotT,fliplr(PlotT)],[aveRetreat-semRetreat,fliplr(aveRetreat+semRetreat)],'b','facealpha',0.3, 'LineStyle','none');
            hold on
            sem3=fill([PlotT,fliplr(PlotT)],[avePush-semPush,fliplr(avePush+semPush)],'r','facealpha',0.3, 'LineStyle','none');
            hold on
            if StillN
                plot(PlotT,aveStill,'k');
                hold on
            else
            end
            plot(PlotT,aveRetreat,'b');
            hold on
            plot(PlotT,avePush,'r');
            xlim(range);
            xlabel('Time from onset (s)');
            ylabel('Firing rate');
            title ([ttdata(ff).recName,'_',ttdata(ff).unit(jj).name]);
            
        end
        clearvars pethPush avePush semPush pethRetreat aveRetreat semRetreat pethStill aveStill semStill;
        figfolder=[folderAddress,'\Output new\PETH_all units'];
        if exist(figfolder)==0
            mkdir(figfolder);
        end
        savefig([figfolder,'\',['vv-PETH-',ttdata(ff).recName,'.fig']]);
        saveas(p,[figfolder,'\',['vv-PETH-',ttdata(ff).recName,'.png']],'png');
 
            
end
save([folderAddress,'\Output new\vv-ttdata.mat'], 'ttdata');





    