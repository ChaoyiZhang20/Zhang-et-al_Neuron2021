% plexon .mat file

    clc; clear;
    close all;
    [filename, pathname] = uigetfile('*.mat');
    cd(pathname)
    load(filename);
    
    % need to revise
    evt_name = who('-regexp', 'EVT*');
    event = eval(evt_name{1});
    % applied to 20Hz protocol
    event = [0; event];
    diff_event = diff(event);
    event = event(find(diff_event > 10)+1);

    % clear the variable name contain i_, the unsorted variable of the plexon
    clear -regexp '\w*i_\w*'
    
    % ts_name = who('-regexp', '_ts$'); % $ end with
    ts_name = who('-regexp', 'SPK*'); % * start with
    numCell = length(ts_name);
    
    len = Stop;
    bin = 0.1;
    nbin = ceil(len/bin);
    fr = zeros(numCell, nbin);
    
    if (event(end)+10)<len
        event(end) = [];
    end
    numEvent = length(event);
    
    for i = 1:numCell
        ts{i} = eval(ts_name{i});
        source{i, 1} = [filename(1:end-4), '*', ts_name{i}(1:end-6)];
        for j = 1:length(ts{i})
            idx = ceil(ts{i}(j)/bin);
            fr(i, idx) = fr(i, idx) + 1;
        end
    end
    
    fr = fr/bin;
%     for i = 1:numCell
%         fr_s(i, :) = smooth(fr(i, :), 5, 'moving');
%     end
    fr_s = fr;
    
    psth_t_pre = 60;
    psth_t_ing = 60;
    psth_t_post = 60;
    t = -psth_t_pre:bin:(psth_t_ing + psth_t_post);
    psth = zeros(numEvent, length(t), numCell);
   
    for i = 1:numCell
        for j = 1:numEvent
            idx_start = ceil(event(j)/bin) - floor(psth_t_pre/bin);
            idx_stop = ceil(event(j)/bin) + floor((psth_t_ing + psth_t_post)/bin);
            psth(j, :, i) = fr_s(i, idx_start:idx_stop);
        end
    end
    
    for i = 1:size(psth, 3)
        a(:, i) = mean(psth(:, 1:length(-psth_t_pre:bin:0), i), 2);
        b(:, i) = mean(psth(:, length(-psth_t_pre:bin:0):length(-psth_t_pre:bin:0)+length(bin:bin:psth_t_ing), i), 2);
        [h(i), p(i)] = ttest(a(:, i), b(:, i));
    end
    r = mean(b, 1) ./ mean(a, 1);
    idx_act = find(p<0.05 & r>1);
    idx_inb = find(p<0.05 & r<1);
    
%     % check the consistency of the firing rate during the recording session
%     i = (a(numEvent, :) + a(numEvent-1, :)) ./ (a(1, :) + a(2, :));
%     idx = find(i == 0 | i > 100)
%     for i = 1:length(idx)
%         figure
%         imagesc(psth(:, :, idx(i)))
%         prompt = ['#Cell', num2str(idx(i))];
%         dlg_title = 'Cell Exclusion';
%         num_lines = 1;
%         definput = {''};
%         opt.WindowStyle = 'normal';
%         answer{i} = inputdlg(prompt, dlg_title, num_lines, definput, opt);
%     end
    
    psth_mean = squeeze(mean(psth, 1))';
    [~, token, ~] = fileparts(filename);
    filename = ['psth_', token, '.mat'];
    save(filename, 'fr_s', 'psth_mean', 'psth', 'bin', 'source', 'psth_t_pre', ...
        'psth_t_ing', 'psth_t_post', 't')
    
%     % sorting
    idx_event_start = length(-psth_t_pre:bin:0);
    idx_event_end = idx_event_start + length(0:bin:psth_t_ing);
    
    psth_pre = psth(:, 1:idx_event_start-1, :);
    psth_ing = psth(:, idx_event_start:idx_event_end-1, :);
    psth_post = psth(:, idx_event_end:end, :);
    
    psth_pre_mean = squeeze(mean(psth_pre, 2));
    psth_ing_mean = squeeze(mean(psth_ing, 2));
    psth_post_mean = squeeze(mean(psth_post, 2));
    % sort according to the after/before
    idx1 = find(r>1);
    [~, idx] = sort(r(idx1), 'descend');
    idx1 = idx1(idx);
    psth_mean_1 = psth_mean(idx1, :);
    
    figure
    imagesc(t, 1:numCell, psth_mean)
    xlabel('seconds')
    ylabel('units')