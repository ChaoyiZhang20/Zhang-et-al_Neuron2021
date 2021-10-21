% coded by zfqy
% version: V0.1
% last edit: Jan 15,2020

function transient = transientDetection(dff,threStd)

%% smooth
% dff = arrayfun(@(x) smooth(dff(x,:),51,'sgolay',2),...
%     1:size(dff,1),'uniformoutput',false);
% dff = cell2mat(dff)';

%% correct baseline (mean -> 0)
[dff,~] = arrayfun(@(x) baselineEst(1:size(dff,2),dff(x,:)),...
    1:size(dff,1),'uniformoutput',false);
dff = cell2mat(dff');

%% standard deviation calculation
% stdVal = movstd(dff',200)';
stdVal = std(dff,[],2);

%% transient detection
transient = arrayfun(@(x) dff(x,:)>threStd*stdVal(x,:),...
    1:size(dff,1),'uniformoutput',false);
transient = cell2mat(transient');

%% merge nearest section
combineThre = 20;
transient = combineThredLoc(transient,combineThre);


