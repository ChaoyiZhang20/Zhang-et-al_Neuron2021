function var = extractEvent_time(z, event, pars)
% Function:
% Input:
% Output:
% Author: Zheyi Ni, 20180308 ver 2.0
% 修正modifier的数量 framerate改成系统参数 pairs point extractor
% 待修正 psth_pre and post in not count in
% fiber photometry version
    
    c = [event.Behavior, event.Modifier1, event.Subject];
    if strcmp(pars.extractorType, 'Single')
        numExtractor = length(pars.extractor);
        idx_extractor = ones(length(event.Behavior), 1);
        for i = 1:numExtractor
            [~, j] = find(strcmp(c, pars.extractor{i}), 1, 'first');
            idx_extractor = idx_extractor & strcmp(c(:, j), pars.extractor{i});
        end
        if strcmp(pars.status, 'State')
            idx_event_start = find(idx_extractor & strcmp(event.Status, 'START'));
            idx_event_end = find(idx_extractor & strcmp(event.Status, 'STOP'));

            idx_rsp_start = max(1, floor((event.Time(idx_event_start) + pars.psth_pre) * pars.fs)); %index of endoscope;
            idx_rsp_end = min(length(z), ceil((event.Time(idx_event_end) + pars.psth_post) * pars.fs));
            dur = idx_rsp_end - idx_rsp_start + 1; % num of ele
        elseif strcmp(pars.status, 'Point')
            idx_event_point = find(idx_extractor & strcmp(event.Status, 'POINT'));

            idx_rsp_start = max(1, floor((event.Time(idx_event_point) + pars.psth_pre) * pars.fs));
            idx_rsp_end = min(length(z), ceil((event.Time(idx_event_point) + pars.psth_post) * pars.fs));
            dur = idx_rsp_end - idx_rsp_start + 1; % num of ele;
        end
    elseif strcmp(pars.extractorType, 'Pairs') 
        idx_extractor = ones(length(event.Behavior), 2);
        for i = 1:2
            numExtractor = length(pars.extractor{i});
            for j = 1:numExtractor
                [~, k] = find(strcmp(c, pars.extractor{i}{j}), 1, 'first');
                idx_extractor(:, i) = idx_extractor(:, i) & strcmp(c(:, k), pars.extractor{i}{j});
            end
        end
        if strcmp(pars.status, 'Point') % 提取[extractor1, extractor2]的信号
            idx_event_start = find(idx_extractor(:, 1));
            idx_event_end = find(idx_extractor(:, 2));

            idx_rsp_start = max(1, floor((event.Time(idx_event_start) + pars.psth_pre) * pars.fs)); %index of endoscope;
            idx_rsp_end = min(length(z), ceil((event.Time(idx_event_end) + pars.psth_post) * pars.fs));
            dur = idx_rsp_end - idx_rsp_start + 1; % num of ele;
        end
    end
    
    rsp = {};
    figure
    plot(z)
    hold on
    for i = 1:length(idx_rsp_start)
        rsp{i} = z(idx_rsp_start(i):idx_rsp_end(i));
        y = floor(min(z)):0.1:ceil(max(z));
        plot(repmat(idx_rsp_start(i), 1, length(y)), y, 'r--')
        hold on
        plot(repmat(idx_rsp_end(i), 1, length(y)), y, 'g--')
        hold on
    end
    
    var = struct('rsp', {rsp}, 'dur', dur, 'psth_pre', pars.psth_pre,...
        'psth_post', pars.psth_post, 'extractor',{pars.extractor},...
        'extractorType', {pars.extractorType}, 'status', pars.status,...
        'fs', pars.fs);
%     save(filename, '-struct', 'var')
end