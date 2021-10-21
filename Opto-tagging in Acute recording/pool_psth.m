clc; clear;
close all;
[filename, pathname] = uigetfile('*.mat', 'MultiSelect', 'on');

for i = 1:length(filename)
    in = load(fullfile(pathname, filename{i}), 'psth');
    x = getfield(in, 'psth');
    numTrials(i) = size(x, 1);
    numBins(i) = size(x, 2);
    numCells(i) = size(x, 3);
end

psth = [];
source = [];
for i = 1:length(filename)
    x = load(fullfile(pathname, filename{i}));
    if size(x.psth, 1) < max(numTrials)
        x.psth = cat(1, x.psth, NaN(max(numTrials) - size(x.psth, 1), size(x.psth, 2), size(x.psth, 3))); % filling the repeats with NaNs
    end
    psth = cat(3, psth, x.psth(:, 1:min(numBins), :));
    source = [source; x.source];
end

bin = x.bin;
psth_t_pre = x.psth_t_pre;
psth_t_ing = x.psth_t_ing;
psth_t_post = x.psth_t_post;
t = x.t;

psth_mean = squeeze(mean(psth, 1, 'omitnan'))';
figure
imagesc(psth_mean)

filename = 'psth_all_stat';
save(filename, 'psth_mean', 'psth', 'bin', 'source', 'psth_t_pre', ...
        'psth_t_ing', 'psth_t_post', 't')