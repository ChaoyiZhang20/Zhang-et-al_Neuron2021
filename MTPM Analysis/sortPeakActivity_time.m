function [sorted, idx, fr] = sortPeakActivity_time(Z)
    for i = 1:size(Z, 1)
        [~, locs] = findpeaks(Z(i, :), 'MinPeakProminence', 1.5);% 1.5 可以调整thre
        if isempty(locs)
            locs_1st(i) = size(Z, 2);
        else
            locs_1st(i) = min(locs);
        end
        fr(i) = length(locs);
    end
    [~, idx] = sort(locs_1st, 'ascend');
    sorted = Z(idx, :);
    figure
    imagesc(sorted)
end