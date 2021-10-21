    clc; clear; 
    close all;
    [filename_pool, pathname_pool] = uigetfile('*.mat', 'Select pool waveform data');
    load(fullfile(pathname_pool, filename_pool));
    [filename_psth, pathname_psth] = uigetfile('*.mat', 'Select pool psth data');
    load(fullfile(pathname_psth, filename_psth));
    
    for i = 1:size(psth, 3)
        a(:, i) = mean(psth(:, 1:length(-psth_t_pre:bin:0)-1, i), 2);
        b(:, i) = mean(psth(:, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:psth_t_ing)), i), 2);
        c(:, i) = mean(psth(:, (length(-psth_t_pre:bin:0)+length(bin:bin:psth_t_ing)):end, i), 2);
        [~, p(i)] = signrank(a(:, i), b(:, i));
    end
    
    r = (mean(b, 1)-mean(a, 1)) ./ (mean(b, 1)+mean(a, 1));
    [b_sort, idx_sort_include] = sort(r(idx_include), 'descend');
    idx_sort_nan = find(isnan(r(idx_include(idx_sort_include))));
    idx_sort_include(idx_sort_nan) = [];
    idx_sort_include = [idx_sort_include, idx_sort_nan];
    
    idx_act = find(p<0.05 & r>0);
    idx_inb = find(p<0.05 & r<0);
    idx_act_include = intersect(idx_act, idx_include);
    idx_inb_include = intersect(idx_inb, idx_include);
    idx_fs_include = intersect(idx_fs, idx_include);
    idx_fs_act_inclusion = intersect(idx_fs_include, idx_act_include);
    idx_fs_inb_inclusion = intersect(idx_fs_include, idx_inb_include);
    
    idx_ns = setdiff(idx_ns, idx_tag);
    idx_fs = setdiff(idx_fs, idx_tag);
    idx_ws = setdiff(1:size(psth_mean, 1), idx_ns);
    idx_ws = setdiff(idx_ws, idx_tag);
    idx_ws_act = intersect(idx_ws, idx_act_include);
    idx_ws_inb = intersect(idx_ws, idx_inb_include);
    idx_ns_inb = intersect(idx_ns, idx_inb_include);
    idx_ns_act = intersect(idx_ns, idx_act_include);
    idx_fs_inb = intersect(idx_fs, idx_inb_include);
    idx_fs_act = intersect(idx_fs, idx_act_include);
    
    for i = 1:size(psth_mean, 1)
        if std(a(:, i), 1) ~= 0
            psth_mean_norm(i, :) = (psth_mean(i, :) - mean(a(:, i))) / std(a(:, i));
        else
            psth_mean_norm(i, :) = psth_mean(i, :);
        end
    end
    
    for i = 1:size(psth_mean_s, 1)
        if std(psth_mean_s(i, 1:length(-psth_t_pre:bin:0))) ~= 0
            psth_mean_norm_s(i, :) = (psth_mean_s(i, :) - mean(psth_mean_s(i, 1:length(-psth_t_pre:bin:0)))) / std(psth_mean_s(i, 1:length(-psth_t_pre:bin:0)));
        else
            psth_mean_norm_s(i, :) = psth_mean_s(i, :);
        end
    end
    
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_tag, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_tag, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_tag)), 'k')
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_ws_act, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_ws_act, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_ws_act)), 'k')
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_ws_inb, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_ws_inb, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_ws_inb)), 'k')
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_ns_act, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_ns_act, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_ns_act)), 'k')
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_ns_inb, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_ns_inb, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_ns_inb)), 'k')
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_fs_act, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_fs_act, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_fs_act)), 'k')
    figure
    errorbar_revised(900:1100, mean(psth_mean_norm_s(idx_fs_inb, 900:1100), 1, 'omitnan'), std(psth_mean_norm_s(idx_fs_inb, 900:1100), 0, 1, 'omitnan')/sqrt(length(idx_fs_inb)), 'k')
    
    [m, idx_peak_tag] = max(psth_mean_s(idx_tag, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.05))), [], 2);
    idx_temp = find(m<1.96);
    idx_peak_tag(idx_temp) = nan;
    clearvars m idx_temp
    [m, idx_peak_fs_act] = max(psth_mean_s(idx_fs_act, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.05))), [], 2);
    idx_temp = find(m<1.96);
    idx_peak_fs_act(idx_temp) = nan;
    clearvars m idx_temp
    [m, idx_peak_ns_act] = max(psth_mean_s(idx_ns_act, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.05))), [], 2);
    idx_temp = find(m<1.96);
    idx_peak_ns_act(idx_temp) = nan;
    clearvars m idx_temp
    [m, idx_peak_ws_act] = max(psth_mean_s(idx_ws_act, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.05))), [], 2);
    idx_temp = find(m<1.96);
    idx_peak_ws_act(idx_temp) = nan;
    clearvars m idx_temp
    [m, idx_trough_fs_inb] = min(psth_mean_s(idx_fs_inb, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.03))), [], 2);
    idx_temp = find(m>-1.96);
    idx_peak_fs_inb(idx_temp) = nan;
    clearvars m idx_temp
    [m, idx_trough_ns_inb] = min(psth_mean_s(idx_ns_inb, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.03))), [], 2);
    idx_temp = find(m>-1.96);
    idx_peak_ns_inb(idx_temp) = nan;
    clearvars m idx_temp
    [m, idx_trough_ws_inb] = min(psth_mean_s(idx_ws_inb, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.03))), [], 2);
    idx_temp = find(m>-1.96);
    idx_peak_ws_inb(idx_temp) = nan;
    clearvars m idx_temp
    
    figure
    imagesc(psth_mean_norm(idx_include, :), [-1 2])
    figure
    plot(mean(psth_mean_norm(idx_include, :), 1, 'omitnan'))
    
    figure
    imagesc(psth_mean_norm(idx_include(idx_sort_include), :), [-1 2])