
clc; clear; 
close all;
%% Initiation

Fs = 50; %sample rate
ctrltime = [-3, -1];

  
    %% Load Fiber Photometry Data & Events

    [event_filename, pathname] = uigetfile('*.mat', 'Select the behavior events');
event = load(fullfile(pathname, event_filename));
    
    [filename, pathname] = uigetfile('*.mat', 'Open fiber photometry Cal file');
x = load((fullfile(pathname, filename)));
 
 beh_time=roundn(event.Time,-1)

x=x.data(:,4)

offset=14.2 % need to revised

x1=x(:,1)-offset

baseline=beh_time(1,1)*100;
baseline=roundn(baseline,0);
V_baseline=ones(baseline,1)*x1(1,1);

x3=[V_baseline;x1]

s=x3

 %% Signal Extraction
    extractor = { {{'push'}}};
    state = {'State'};
    for i = 1:length(extractor)
        vars{i}.extractorType = 'Single';
        vars{i}.status = state{i};
        vars{i}.extractor = extractor{i};
        vars{i}.psth_pre = -3; % the same unit as event.Time, [-inf, 0] -20
        vars{i}.psth_post = 3; % the same unit as event.Time, [0, inf] 20 
        vars{i}.ctrltime = ctrltime;
        vars{i}.fs = Fs;
        signal_event_epoch{i} = extractEventVer2_time(s, event, vars{i});
        psth{i} = plot_psth(signal_event_epoch{i}.rsp, vars{i});
    end

  
final_psth=psth{1,1}(:,1:350)

figure
imagesc(final_psth)