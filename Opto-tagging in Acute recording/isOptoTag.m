function [accuracy, p, latency, jitter] = isOptoTag()

    clc; clear;
%     close all;
    [filename, pathname] = uigetfile('*.mat', 'plx_');
    cd(pathname)
    load(filename);
    
    evt_name = who('-regexp', 'EVT*');
    event = eval(evt_name{1});
    numEvent = length(event);
    
    ts_name = who('-regexp', 'ts$');
    numCell = length(ts_name);
    
    %%% interface for SALT (significance based)
    
    p = zeros(numCell, 1);
    dt = 0.001; % unit s
    wn = 0.01; % unit s
    psth_t_pre = 5 * wn;
    psth_t_post = 5 * wn;

    len = Stop;
    numEvents = length(event);
    
    for i = 1:numCell
        fr = zeros(ceil(len/dt), 1);
        spt_baseline = zeros(numEvents, ceil(psth_t_post/dt));
        spt_test = zeros(numEvents, ceil(psth_t_pre/dt));
        ts{i} = eval(ts_name{i});
%         source{i, 1} = [filename(1:end-4), '*', ts_name{i}(1:end-6)];
        for j = 1:length(ts{i})
            idx = ceil(ts{i}(j)/dt);
            fr(idx, 1) = fr(idx, 1) + 1;
        end

        for j = 1:numEvent
            idx_evt_pre = ceil(event(j)/dt) - floor(psth_t_pre/dt);
            idx_evt = ceil(event(j)/dt);
            idx_evt_post = ceil(event(j)/dt) + floor(psth_t_post/dt);
            spt_test(j, :) = fr(idx_evt+1:idx_evt_post, 1);
            spt_baseline(j, :) = fr(idx_evt_pre:idx_evt-1, 1);
        end
        
        [p(i, 1), ~] = salt(spt_baseline, spt_test, dt, wn);
        clearvars fr spt_baseline spt_test
    end
    
    clearvars fr spt_baseline spt_test ts
    
    %%% threshold of accuracy based identify method
    thr_latency = 0.01;
    accuracy = zeros(numCell, 1);
    latency = zeros(numCell, numEvent);
    jitter = zeros(numCell, 1);
    for i = 1:numCell
        ts{i} = eval(ts_name{i});
        for j = 1:length(event)
            idx = find(ts{i} > event(j), 1, 'first');
            if isempty(idx) || (ts{i}(idx) - event(j) > thr_latency)
                latency(i, j) = NaN;
            else
                latency(i, j) = ts{i}(idx) - event(j);
            end
        end
        accuracy(i, 1) = length(find(latency(i, :) < thr_latency)) / length(event);
        if length(~isnan(latency(i, :))) == 1
            jitter(i, 1) = nan;
        else
            jitter(i, 1) = std(latency(i, :), 0, 2, 'omitnan');
        end
        source{i, 1} = [filename(1:end-4), '*', ts_name{i}(1:end-6)];
    end
    
    filename_save = ['optotag_', filename];
    save(filename_save, 'latency', 'accuracy', 'source', 'p', 'jitter')
end