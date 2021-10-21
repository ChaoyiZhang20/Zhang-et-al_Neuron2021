clc; clear;
close all;

% load data
folderAddress='I:\';
load([folderAddress,'\Total-ttdata.mat']);
load([folderAddress,'\Total-TagData.mat']);

nFiles = size(OptoTag, 2);
for i = 1 : nFiles  %nFiles
    if length(ttdata(i).unit) ~= length(ttdata(i).unit)
        disp(ttdata(i).recName)
    end
    nCellperFile(i) = length(ttdata(i).unit);
end
nCell = sum(nCellperFile);
nTimes = size(ttdata(1).unit(1).periPush, 2);

psth_push = zeros(nCell, nTimes);
psth_retreat = zeros(nCell, nTimes);
celltype = cell(nCell, 1);

% 
cnt = 1;
testfor = [31:60]; % [-1.5, 0]
baseline = [1:30]; % [-3, -1.5]
for i = 1 : nFiles   %%nFiles
    for j = 1:nCellperFile(i)
        psth_push(cnt, :) = zscore_revised(squeeze(ttdata(i).unit(j).periPush), baseline(end));
        [p_push(cnt, :), h_push(cnt, :), r_push(cnt, :)] = signrank_revised(ttdata(i).unit(j).periPush(:,testfor), ttdata(i).unit(j).periPush(:,baseline));
        t_push(cnt, :) = find1stsig(p_push(cnt, :), baseline(end));
        
        psth_retreat(cnt, :) = zscore_revised(squeeze(ttdata(i).unit(j).periRetreat), baseline(end));
        [p_retreat(cnt, :), h_retreat(cnt, :), r_retreat(cnt, :)] = signrank_revised(ttdata(i).unit(j).periRetreat(:,testfor), ttdata(i).unit(j).periRetreat(:,baseline));
        t_retreat(cnt, :) = find1stsig(p_retreat(cnt, :), baseline(end));
        celltype{cnt, 1} = OptoTag(i).unit(j).classification;
        cnt = cnt + 1;
    end
end

[idx_push_exc, idx_push_ihb] = get_ext_ihb(t_push, r_push, baseline(end)-1);
[idx_retreat_exc, idx_retreat_ihb] = get_ext_ihb(t_retreat, r_retreat, baseline(end)-1);

idx_pv = find(strcmp(celltype, 'pPV') | strcmp(celltype, 'pFSI'));
idx_pyr = find(strcmp(celltype, 'WS'));
idx_ns = find(strcmp(celltype, 'NS'));

pv_push_exc = intersect(idx_pv, idx_push_exc);
[~, idx] = sort(t_push(pv_push_exc));
pv_push_exc = pv_push_exc(idx);

pv_push_ihb = intersect(idx_pv, idx_push_ihb);
[~, idx] = sort(t_push(pv_push_ihb));
pv_push_ihb = pv_push_ihb(idx);

pyr_push_exc = intersect(idx_pyr, idx_push_exc);
[~, idx] = sort(t_push(pyr_push_exc));
pyr_push_exc = pyr_push_exc(idx);

pyr_push_ihb = intersect(idx_pyr, idx_push_ihb);
[~, idx] = sort(t_push(pyr_push_ihb));
pyr_push_ihb = pyr_push_ihb(idx);

[~, idx_push_sort] = sort(mean(psth_push(:, 50:70), 2), 'descend');
psth_push_sort = psth_push(idx_push_sort, :);
[~, idx_retreat_sort] = sort(mean(psth_retreat(:, 50:70), 2), 'descend');
psth_retreat_sort = psth_retreat(idx_retreat_sort, :);
figure
imagesc(psth_push_sort(idx_pyr, 1:120), [-0.25 0.25])
title('push pyr')

figure
imagesc(psth_push_sort(idx_pv, 1:120), [-0.25 0.25])
title('push pv')

t_pv_push_ihb = t_push(pv_push_ihb);
t_pv_push_exc = t_push(pv_push_exc);
t_pyr_push_exc = t_push(pyr_push_exc);
t_pyr_push_ihb = t_push(pyr_push_ihb);

[h, p] = kstest2(t_pv_push_ihb, t_pyr_push_exc)
[p, h] = ranksum(t_pv_push_ihb, t_pyr_push_exc)

[h, p] = kstest2(t_pv_push_ihb, t_pv_push_exc)
[p, h] = ranksum(t_pv_push_ihb, t_pv_push_exc)

[h, p] = kstest2(t_pv_push_exc, t_pyr_push_exc)
[p, h] = ranksum(t_pv_push_exc, t_pyr_push_exc)


figure   %figure5
cdfplot(t_push(pv_push_ihb))
hold on
cdfplot(t_push(pyr_push_exc))
hold on 
cdfplot(t_push(pv_push_exc))
set(gca, 'xtick', 30:10:71)
set(gca, 'xticklabel', -1.5:0.5:0.5)
legend('pv_push_ihb', 'pyr_push_exc', 'pv_push_exc')

function z_mean = zscore_revised(x, basIdx)
    z = zeros(size(x));
    base = x(:, 1 : basIdx);
    base_mean = mean(base(:), 1);
    base_std = std(base(:), 0, 1);
    for i = 1:size(x, 1)
        if base_std == 0 
            z(i, :) = x(i, :) - base_mean;
        else
            z(i, :) = (x(i, :) - base_mean) / base_std;
        end
    end
    z_mean = smooth(mean(z, 1, 'omitnan'), 5);
end

function [p, h, r] = signrank_revised(x, bas)
    width = 2;
    p = zeros(size(x, 2)-width, 1);
    h = zeros(size(x, 2)-width, 1);
    r = zeros(size(x, 2)-width, 1);
    base = mean(bas, 2);
    
    for i = 1:size(x, 2)-width
        extr = mean(x(:, i : i + width), 2);
        [p(i, 1), h(i, 1)] = signrank(base, extr);
        r(i, 1) = (mean(extr) - mean(base)) / (mean(extr) + mean(base));
    end

end

function idx = find1stsig(p, basIdx)
    for i = 1:size(p, 1)
        p(i, :) = mafdr(p(i, :), 'BHFDR', true);
    end
    
    idx = find(p < 0.05, 1);
    if isempty(idx)
        idx = nan;
    else
        idx = idx + basIdx - 1;
    end
end

function [idx_ext, idx_ihb] = get_ext_ihb(t, r, n)
    idx_ext = [];
    idx_ihb = [];
    for i = 1:length(t)
        if isnan(t(i))
            continue
        elseif r(i, t(i)-n) > 0
            idx_ext = [idx_ext, i];
        elseif r(i, t(i)-n) < 0
            idx_ihb = [idx_ihb, i];
        end
    end
end