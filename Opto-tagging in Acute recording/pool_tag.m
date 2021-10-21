clc; clear;
close all;
[filename, pathname] = uigetfile('*.mat', 'MultiSelect', 'on');
cd(pathname)
latency = [];
accuracy = [];
p = [];
jitter = [];
source = {};
for i = 1:length(filename)
    x = load(fullfile(pathname, filename{i}));
    latency = [latency; mean(x.latency, 2, 'omitnan')];
    accuracy = [accuracy; x.accuracy];
    p = [p; x.p];
    jitter = [jitter; x.jitter];
    source = [source; x.source];
end

figure
plot(latency)
figure
plot(accuracy)
figure
plot(p)

thr_p = 0.001;
thr_latency = 0.005;
thr_jitter = 0.003;
idx_tag = find((p < thr_p) & (latency < thr_latency) & (jitter < thr_jitter));

filename = 'optotag_all_stat';
save(filename, 'latency', 'accuracy', 'p',  'source', 'idx_tag', 'jitter')