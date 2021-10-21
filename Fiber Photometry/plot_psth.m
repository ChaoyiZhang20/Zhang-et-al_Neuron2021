function [psth] = plot_psth(x, vars)
% x is a cell
% plot matrix and mean¡Àstd
% 20190923
    
    numBouts = length(x);
    dur = zeros(1, numBouts);
    for i = 1:numBouts
        dur(i) = length(x{i});
    end
    m = zeros(numBouts, max(dur));
    
    if isempty(vars.ctrltime)
        for i = 1:numBouts
            m(i, 1:dur(i)) = x{i};
        end
        
    else
        idx_ctrl_start = (vars.ctrltime(1)-vars.psth_pre)*vars.fs+1;
        idx_ctrl_end = (vars.ctrltime(2)-vars.psth_pre)*vars.fs+1;
        for i = 1:numBouts
            n = mean(x{i}(idx_ctrl_start:idx_ctrl_end));
            m(i, 1:dur(i)) = (x{i} - n) / n;% ×¢ÊÍF/F
            zcy(i, 1:dur(i))= x{i};
    
        end
    end
    
    numcell= size(zcy,1)


mean_baseline= mean(zcy(:,1:150),2);

std_baseline = std(zcy(:,1:150),1,2);

for i = 1:numcell
    zscore(i,:)=(zcy(i,:)-mean_baseline(i))/std_baseline(i);
end
   F_F=m
    save('raw.mat','zcy','F_F','zscore')
   tmin = vars.psth_pre + 1/vars.fs;
    tmax = max(dur)/vars.fs + vars.psth_pre;
    t = tmin : 1/vars.fs : tmax;
    figure
    imagesc(t, 1:numBouts, m, [-0.01, 0.01])
    xlabel('Time (s)')
    ylabel('# Bouts')
%     clims = [-5 5];
%     imagesc(m, clims);

    % plot end line
    for i = 1:numBouts
        hold on
        plot(ones(1, 2) * (dur(i)/vars.fs + vars.psth_pre), [i-0.5, i+0.5], 'k', 'linewidth', 5);
    end
    % plot zero line
    
    y = 0:0.5:(numBouts+0.5);
    plot(zeros(1, length(y)), y, 'r', 'linewidth', 2)
    
    tmin = vars.psth_pre + 1/vars.fs;
    psth = m(:, 1:max(dur));
    mean_x = mean(m(:, 1:max(dur)));
    std_x = std(m(:, 1:max(dur))) / sqrt(length(numBouts));
    tmax = max(dur)/vars.fs + vars.psth_pre;
    t = tmin : 1/vars.fs : tmax;
    errorbar_revised(t, mean_x, std_x)
    [h, p] = ttest2(mean(m(:, idx_ctrl_start:idx_ctrl_end), 2), mean(m(:, idx_ctrl_start+175:idx_ctrl_start+225), 2))
end