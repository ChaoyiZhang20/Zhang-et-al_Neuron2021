% coded by zfqy
% version v0.1
% last edit: Jan 11, 2020

function [keepId,rmvId] = traceQualityEval(trace_orig,trace_ring,dff,psdThre)

%% remove low SNR cell according to power spectral density
dff_norm = mapminmax(dff,0,1);
psdCollect = [];
for i = 1:size(dff_norm,1)
    psdCollect(i) = mean((dff_norm(i,:)-smooth(dff_norm(i,:),21,'sgolay',10)').^2);
end
rmvLowSNR = find(psdCollect>psdThre)';

%% remove cell having high similarity between trace and ring
simiThre = 0.95;
sbr = diag(corr(trace_orig',trace_ring'));
rmvSimi = find(sbr>simiThre);

%% excute
rmvId = union(rmvLowSNR,rmvSimi);
keepId = setdiff(1:size(dff,1),rmvId);