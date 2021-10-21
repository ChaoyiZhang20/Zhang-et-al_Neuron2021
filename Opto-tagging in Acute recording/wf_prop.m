
    clc; clear;
    close all
    [filename, pathname] = uigetfile('*.mat');
    load(fullfile(pathname, filename));
    
    baselinetime = [0, 60]; %
    thr = 0.004;
    fs = 40000; % Hz
    % wavelength = 1400; % us
    % interval = wavelength/(1/fs*1e6); % us

    % clear the variable name contain i_, the unsorted variable of the plexon
    clear -regexp '\w*i_\w*'

    ts_name = who('-regexp', 'ts$');
    ts_name = who('-regexp', '^ts');
    for i = 1:length(ts_name)
        ts{i} = eval(ts_name{i});
        y.interval{i, 1} = diff([0, ts{i}, Stop(end)]);
        y.fr(i, 1) = length(find((ts{i} >  baselinetime(1)) & (ts{i} <  baselinetime(2))))/(baselinetime(2) - baselinetime(1)); % need to revise
    end

    wf_name = who('-regexp', 'wf$');
    for i = 1:length(wf_name)
        wf{i} = eval(wf_name{i});
        y.wf_mean(i, :) = mean(wf{i}, 2);
        % peak < 0
        [pks1, locs1, w1, ~]= findpeaks(y.wf_mean(i, :), 'MinPeakHeight', thr, 'WidthReference', 'halfheight'); % > 0
        [pks2, locs2, w2, ~]= findpeaks(-y.wf_mean(i, :), 'MinPeakHeight', thr, 'WidthReference', 'halfheight'); % < 0
        % peak > 0
        if max(pks1) > max(pks2)
            y.wf_mean(i, :) = -y.wf_mean(i, :);
            [pks1, locs1, w1, ~]= findpeaks(y.wf_mean(i, :), 'MinPeakHeight', thr, 'WidthReference', 'halfheight');
            [pks2, locs2, w2, ~]= findpeaks(-y.wf_mean(i, :), 'MinPeakHeight', thr, 'WidthReference', 'halfheight');
        end

        [~, idx_peak(i)] = max(pks2);
        % peak half width
        peak_width(i) = w2(idx_peak(i));
        y.peak_width(i, 1) = peak_width(i) / fs * 1e6; % us

        idx_peak(i) = locs2(idx_peak(i));

        [pks1, idx] = sort(pks1, 'descend');
        locs1 = locs1(idx);
        w1 = w1(idx);
        for j = 1:length(locs1)
            if locs1(j) > idx_peak(i) && w1(j) == max(w1)
                idx_trough(i) = j;
            end
        end
        try 
            % trough half width
            trough_width(i) = w1(idx_trough(i));
            y.trough_width(i, 1) = trough_width(i) / fs * 1e6; % us

            idx_trough(i) = locs1(idx_trough(i));
            % peak-trough ratio
            y.pt_ratio(i, 1) = abs(max(pks2)/max(pks1));
            % peak-trough width
            pt_width(i) = (idx_trough(i) - idx_peak(i));
            y.pt_width(i, 1) = pt_width(i) / fs * 1e6; % us
            y.source{i, 1} = [filename(1:end-4), '*', wf_name{i}(1:end-3)];
        catch
            disp('Valley Identification Warning')
            y.trough_width(i, 1) = NaN;
            y.pt_ratio(i, 1) = NaN;
            y.pt_width(i, 1) = NaN;
            y.source{i, 1} = [filename(1:end-4), '*', wf_name{i}(1:end-3)];
        end
    end
    
    [~, token, ~] = fileparts(filename);
    filename = ['wf_', token, '.mat'];
    save(filename, '-struct', 'y')
