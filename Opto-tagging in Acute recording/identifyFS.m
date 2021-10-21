function idx_fs = identifyFS(x, y, z)
% Parameters are chosed according to :
% Anatol Kreitzer et al., (2016) Fast-Spiking Interneurons Supply Feedforward
% Control of Bursting, Calcium, and Plasticity for Efficient Learning,
% Cell.
% nizheyi 20200506

    if nargin == 0
        [filename, pathname] = uigetfile('*.mat');
        load(fullfile(pathname, filename));
    else
        pt_width = x;
        fr = y;
        trough_width = z;
    end
    fr_thr = 8; % Hz
    pt_width_thr = 400; % us
    
    idx_fs = find(fr>fr_thr & pt_width<pt_width_thr);
    idx_pn = setdiff(1:length(fr), idx_fs);
    
    figure
    scatter3(fr(idx_fs), pt_width(idx_fs), trough_width(idx_fs), 'filled', 'r')
    hold on
    scatter3(fr(idx_pn), pt_width(idx_pn), trough_width(idx_pn), 'filled', 'k')
    xlabel('Firing rate')
    ylabel('Peak Trough Width')
    zlabel('Trough Width')
    legend('FS', 'PN')