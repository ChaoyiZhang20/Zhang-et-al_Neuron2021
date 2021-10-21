 clc; clear;
 close all
 [filename_wf, pathname_wf] = uigetfile('*.mat', 'wf_xxx.mat', 'MultiSelect', 'on');
 cd(pathname_wf)
 [filename_tag, pathname_tag] = uigetfile('*.mat', 'opto_xxx.mat');
 
 fr = [];
 peak_width = [];
 pt_ratio = [];
 pt_width = [];
 trough_width = [];
 wf_mean = [];
 source = {};
 interval = {};
 for i = 1:length(filename_wf)
    x = load(fullfile(pathname_wf, filename_wf{i}));
    fr = [fr; x.fr];
    peak_width = [peak_width; x.peak_width];
    pt_ratio = [pt_ratio; x.pt_ratio];
    pt_width = [pt_width; x.pt_width];
    trough_width = [trough_width; x.trough_width];
    wf_mean = [wf_mean; x.wf_mean];
    source = [source; x.source];
    interval = [interval; x.interval];
 end
 
 y.fr = fr;
 y.pt_ratio = pt_ratio;
 y.pt_width = pt_width;
 y.trough_width = trough_width;
 y.wf_mean = wf_mean;
 y.source = source;
 y.interval = interval;
 
 in = load(fullfile(pathname_tag, filename_tag), 'idx_tag');
 idx_tag = in.idx_tag;
    
 idx_exclusion_fr = find(fr < 1);
 idx_exclusion_interval = isEverExist(y);
%  idx_exclusion_identical = isIdenticalNeuron(y);
 idx_exclusion = union(idx_exclusion_fr, idx_exclusion_interval);
%  idx_exclusion = union(idx_exclusion, idx_exclusion_identical);
 idx_include = setdiff(1:length(source), idx_exclusion);
 idx_fs = identifyFS(pt_width, fr, trough_width);
 
 hold on
 scatter3(fr(idx_tag), pt_width(idx_tag), trough_width(idx_tag), 'MarkerEdgeColor', 'b', 'LineWidth', 2)
 filename_save = 'wf_stat_all.mat';
 save(filename_save, 'fr', 'peak_width', 'pt_ratio', 'pt_width', 'trough_width', ...
     'wf_mean', 'source', 'idx_include', 'idx_fs', 'idx_tag')