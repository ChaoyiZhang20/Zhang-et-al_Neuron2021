function [PushT,RetreatT,StillT]=Events(behavior, behaviorTime, Threshold)
% 20210615 H. Zhu
% 1) combine adjacent (interval<Threshold(1)) and the same kind of behaviors into one
% bout
% 2) exclude bouts with short duration (duration<Threshold(2))
% 3) exclude bouts that other behaviors happen in pre-zero baseline [Threshold(3) 0]
%% deciding if reading paired annotation
behaviorTime(find(1-(strcmp(behavior(:,1), 'push')+strcmp(behavior(:,1), 'retreat')+strcmp(behavior(:,1), 'stillness in tube'))))=[];
behavior(find(1-(strcmp(behavior(:,1), 'push')+strcmp(behavior(:,1), 'retreat')+strcmp(behavior(:,1), 'stillness in tube'))),:)=[];
if mod(size(behavior,1),2)
    warning ('unpaired annotation!');
else
end
%% trim time behaviorTime into n*3 matrix, [start stop duration]

EventTime=zeros(size(behavior,1)/2,3);
EventTime(:,1)=behaviorTime(1:2:end); %% start time of single bouts
EventTime(:,2)=behaviorTime(2:2:end); %% end time of single bouts
tempt=behavior(:,1);
EventName = tempt(1:2:end);    %% ethogram of single bouts

%% find out clean start and end time points of the behaviors
Pidx=find(strcmp(EventName,'push'));  % location index for push bouts
PushT=EventTime(Pidx,:);       

Ridx=find(strcmp(EventName,'retreat'));  % location index for the start time of push bouts
RetreatT=EventTime(Ridx,:);

Sidx=find(strcmp(EventName,'stillness in tube'));  % location index for the start time of push bouts
StillT=EventTime(Sidx,:);

%% Combine adjecent behaviors if interval< preset Interval
Pidx2=zeros(length(Pidx)-1,1);
for ii=1:length(Pidx)-1
    Pidx2(ii)=ii;
    if strcmp(EventName(Pidx(ii)+1), 'push')   %%% if next is the same behavior
        if EventTime(Pidx(ii)+1,1)-EventTime(Pidx(ii),2)< Threshold(1)  %% if interval between these two behaviors < Interval threshold
            Pidx2(ii+1)=0;   %% delete start of the next behavior and end of current behavior
            PushT(ii+1,1)=0;
            PushT(ii,2)=PushT(ii+1,2);
        else
        end
    else
    end
    
end
PushT(find(Pidx2==0),:)=[];
Pidx(find(Pidx2==0))=[];

Ridx2=zeros(length(Ridx)-1,1);
for jj=1:length(Ridx)-1
    Ridx2(jj)=jj;
    if strcmp(EventName(Ridx(jj)+1), 'retreat')   %%% if the next is the same behavior
        if EventTime(Ridx(jj)+1,1)-EventTime(Ridx(jj),2)< Threshold(1)  %% if interval between these two behaviors < Interval threshold
            Ridx2(jj+1)=0;   %% delete start of the next behavior and end of current behavior
            RetreatT(jj+1,1)=0;
            RetreatT(jj,2)=RetreatT(jj+1,2);
        else
        end
    else
    end
    
end
RetreatT(find(Ridx2==0),:)=[];
Ridx(find(Ridx2==0))=[];

Sidx2=zeros(length(Sidx)-1,1);
for kk=1:length(Sidx)-1
    Sidx2(kk)=kk;
    if strcmp(EventName(Sidx(kk)+1), 'stillness in tube')   %%% if the next is the same behavior
        if EventTime(Sidx(kk)+1,1)-EventTime(Sidx(kk),2)< Threshold(1)  %% if interval between these two behaviors < Interval threshold
            Sidx2(kk+1)=0;   %% delete start of the next behavior and end of current behavior
            StillT(kk+1,1)=0;
            StillT(kk,2)=StillT(kk+1,2);
        else
        end
    else
    end
    
end
StillT(find(Sidx2==0),:)=[];
Sidx(find(Sidx2==0))=[];

PushT(:,3)=PushT(:,2)-PushT(:,1);
RetreatT(:,3)=RetreatT(:,2)-RetreatT(:,1);
StillT(:,3)=StillT(:,2)-StillT(:,1);

% remove short behaviors if duration<Interval
tempt1=PushT(:,3);
PushT(find(tempt1<Threshold(2)),:)=[];
Pidx(find(tempt1<Threshold(2)))=[];

tempt2=RetreatT(:,3);
RetreatT(find(tempt2<Threshold(2)),:)=[];
Ridx(find(tempt2<Threshold(2)))=[];

tempt3=StillT(:,3);
StillT(find(tempt3<Threshold(2)),:)=[];
Sidx(find(tempt3<Threshold(2)))=[];


% remove start or end points if other push/retreat behaviors happen within Interval
for kk=1:length(Pidx)
    if Pidx(kk)>1
        interval2=EventTime(Pidx(kk),1)-EventTime(Pidx(kk)-1,2);
        if interval2<Threshold(3) & ~strcmp(EventName(Pidx(kk)-1),'stillness in tube')
            Pidx(kk)=0;
        else
        end
    else
    end
end
PushT(find(Pidx==0),:)=[];
Pidx(find(Pidx==0))=[];

for ll=1:length(Ridx)
    if Ridx(ll)>1
        interval3=EventTime(Ridx(ll),1)-EventTime(Ridx(ll)-1,2);
        if interval3<Threshold(3) & ~strcmp(EventName(Ridx(ll)-1),'stillness in tube')
            Ridx(ll)=0;
        else
        end
    else
    end
end
RetreatT(find(Ridx==0),:)=[];
Ridx(find(Ridx==0))=[];

