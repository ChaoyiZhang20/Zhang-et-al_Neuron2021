 
  % for PV NpHR
    clc; clear; 
    close all;
    [filename_pool, pathname_pool] = uigetfile('*.mat', 'Select pool waveform data');
    load(fullfile(pathname_pool, filename_pool));
    [filename_psth, pathname_psth] = uigetfile('*.mat', 'Select pool psth data');
    load(fullfile(pathname_psth, filename_psth));
    
        for i = 1:size(psth, 3)
        a(:, i) = nanmean(psth(:, 1:length(-psth_t_pre:bin:0)-1, i), 2);
        b(:, i) = nanmean(psth(:, length(-psth_t_pre:bin:0):(length(-psth_t_pre:bin:0)+length(bin:bin:0.01)), i), 2); % for 1hz protocol
        c(:, i) = nanmean(psth(:, length(-psth_t_pre:bin:0)+10:(length(-psth_t_pre:bin:0)+length(bin:bin:0.020)), i), 2); % for 1hz protocol
%         [p_b(i),h_b(i)] = signrank(b(:, i), a(:, i));
%         [p_c(i),h_c(i)] = signrank(c(:, i), a(:, i));
        [p_b(i),h_b(i)] = signrank(b(:, i), a(:, i));
        [p_c(i),h_c(i)] = signrank(c(:, i), a(:, i));
        
        end

idx_ws=find(pt_width>400)
idx_ns=find(pt_width<=400)
idx_ns=setdiff(idx_ns,idx_fs)
idx_ws_include=intersect(idx_ws,idx_include)
idx_ns_include=intersect(idx_ns,idx_include)
idx_fsi_include=intersect(idx_fs,idx_include)

       mean_a = mean(a,1);
       mean_c = mean(c,1); 
       mean_a_ws=mean_a(idx_ws_include)
       mean_c_ws=mean_c(idx_ws_include)
        
   r_b = (mean(b, 1)-mean(a, 1)) ./ (mean(b, 1)+mean(a, 1));
   r_c = (mean(c, 1)-mean(a, 1)) ./ (mean(c, 1)+mean(a, 1));

   
    idx_inb = find(p_c < 0.05 & r_c < 0);
   
    idx_act = find(p_c < 0.05 & r_c > 0);
  



idx_ws_act = intersect(idx_ws_include,idx_act);
idx_ns_act = intersect(idx_ns_include,idx_act);
idx_fsi_act = intersect(idx_fsi_include,idx_act);

idx_ws_inb = intersect(idx_ws_include,idx_inb);
idx_ns_inb = intersect(idx_ns_include,idx_inb);
idx_fsi_inb = intersect(idx_fsi_include,idx_inb);

psth = psth(:,51:200,:);  
psth_mean = psth_mean (:,51:200); 

%% Normaliazaion for PSTH

    for i = 1:size(psth_mean, 1)
        if std(a(:, i), 1) ~= 0
            psth_mean_norm(i, :) = (psth_mean(i, :) - mean(a(:, i))) / std(a(:, i));
        else
            psth_mean_norm(i, :) = psth_mean(i, :);   
        end
     mean_psth_norm_c(i,:)= mean(psth_mean_norm(i,51:80));
     
    end


        
%% Plot Whole group heatmap and psth


[~, idx_sort] = sort(mean_psth_norm_c, 'descend');

for i= 1:size(psth_mean, 1)

s_psth_mean_norm(i,:)=smooth(psth_mean_norm(idx_sort(i), :),10)';
 
end

       
 figure
 imagesc(s_psth_mean_norm(idx_include, :),[-1,1])
 colormap jet
 
numtrial=size(s_psth_mean_norm,2);
s_psth_mean_norm_mean=mean(s_psth_mean_norm);
s_psth_mean_norm_sem=std(s_psth_mean_norm)/sqrt(numtrial);
times=1:1:150

figure
plot(times,s_psth_mean_norm_mean,'k')
y1=s_psth_mean_norm_mean+s_psth_mean_norm_sem;
y2=s_psth_mean_norm_mean-s_psth_mean_norm_sem;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'r','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,s_psth_mean_norm_mean,'k')
% ylim([-0.4,0.4])


s_psth_mean_norm_ws = s_psth_mean_norm(idx_ws_include, :);
 figure
 imagesc(s_psth_mean_norm_ws,[-0.5,1])
 colormap jet

numtrial=size(s_psth_mean_norm_ws,2);
s_psth_mean_norm_mean_ws=mean(s_psth_mean_norm_ws);
s_psth_mean_norm_sem_ws=std(s_psth_mean_norm_ws)/sqrt(numtrial);
times=1:1:150

figure
plot(times,s_psth_mean_norm_mean_ws,'k')
y1=s_psth_mean_norm_mean_ws+s_psth_mean_norm_sem_ws;
y2=s_psth_mean_norm_mean_ws-s_psth_mean_norm_sem_ws;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'r','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,s_psth_mean_norm_mean_ws,'k')
ylim([-0.4,0.4])
%% Plot ns heatmap and psth.
% ns_r_c=r_c(idx_ns_include)

idx_ns_mean_c=mean_psth_norm_c(idx_ns_include);

[~, idx_ns_sort] = sort(idx_ns_mean_c, 'descend');


s_psth_mean_norm_ns = s_psth_mean_norm(idx_ns_include, :);  
figure
 imagesc(s_psth_mean_norm_ns,[-0.5,1])
 colormap jet

numtrial=size(s_psth_mean_norm_ns,2);
s_psth_mean_norm_mean_ns=mean(s_psth_mean_norm_ns);
s_psth_mean_norm_sem_ns=std(s_psth_mean_norm_ns)/sqrt(numtrial);
times=1:1:150
figure
plot(times,s_psth_mean_norm_mean_ns,'k')
y1=s_psth_mean_norm_mean_ns+s_psth_mean_norm_sem_ns;
y2=s_psth_mean_norm_mean_ns-s_psth_mean_norm_sem_ns;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'r','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,s_psth_mean_norm_mean_ns,'k')
ylim([-0.4,0.4])
%% Plot fsi heatmap and psth.


idx_fsi_mean_c=mean_psth_norm_c(idx_fsi_include);

[~, idx_fsi_sort] = sort(idx_fsi_mean_c, 'descend');

s_psth_mean_norm_fsi = s_psth_mean_norm(idx_fsi_include, :);
figure
imagesc(s_psth_mean_norm_fsi, [-0.5,1])
colormap jet

numtrial=size(s_psth_mean_norm_fsi,2);
s_psth_mean_norm_mean_fsi=mean(s_psth_mean_norm_fsi);
s_psth_mean_norm_sem_fsi=std(s_psth_mean_norm_fsi)/sqrt(numtrial);
times=1:1:150

figure
plot(times,s_psth_mean_norm_mean_fsi,'k')
y1=s_psth_mean_norm_mean_fsi+s_psth_mean_norm_sem_fsi;
y2=s_psth_mean_norm_mean_fsi-s_psth_mean_norm_sem_fsi;
y3=fliplr(y2);
t = [times, fliplr(times)];
y = [y1,y3];
fill(t,y,'r','EdgeColor','none','FaceAlpha',0.3);
hold on
plot(times,s_psth_mean_norm_mean_fsi,'k')
ylim([-0.4,0.4])

%% sign_num

idx_c_increase=find(p_c <0.05 & r_c >0);
idx_c_decrease=find(p_c <0.05 & r_c <0);

num_c_increase=length(idx_c_increase);
num_c_decrease=length(idx_c_decrease);

%% Plot volcano figure
  figure
  size=40
    scatter(r_c,p_c,size,'k','filled')
    hold on
    scatter(r_c(idx_c_increase),p_c(idx_c_increase),size,'r','filled')
    scatter(r_c(idx_c_decrease),p_c(idx_c_decrease),size,'b','filled')

    xlim([-1,1])
  %% plot pt-width & Fr  
    
    figure
scatter(pt_width(idx_ws_include),fr(idx_ws_include),  30, [0 0 1],  'filled')
hold on
scatter(pt_width(idx_ns_include),fr(idx_ns_include),  30, [201/255 160/255 99/255],  'filled')
hold on
scatter(pt_width(idx_fsi_include),fr(idx_fsi_include),  30, [229/255 136/255 167/255],  'filled')
h_legend=legend(['WS (n = ', num2str(length(idx_ws_include)), ')'], ...
    ['NS (n = ', num2str(length(idx_ns_include)), ')'], ...
    ['FSI (n = ', num2str(length(idx_fsi_include)), ')']);
xlim([0,800])

axis square
set(gca, 'Position',  [0.1, 0.1, 0.5, 0.5]);
set(gca, 'LineWidth', 1)
set(gca, 'FontSize', 10)
set(h_legend, 'FontSize', 10)

%% plot Fr on-off

x = mean(a)';
y = mean(c)';

figure
p1 = scatter(x(idx_ws_include), y(idx_ws_include), 30, [0.8 0.8 0.8],  'filled');
hold on
p2 = scatter(x(idx_ws_act), y(idx_ws_act), 30, [1 0 0],  'filled');
hold on
p3 = scatter(x(idx_ws_inb), y(idx_ws_inb), 30, [0 0 1],  'filled');
hold on
p4 = plot(0:max(x), 0:max(x), 'k--', 'LineWidth', 1.5);

xlim([0 max(y)])
ylim([0 max(y)])
xlabel('Light Off')
ylabel('Light On')


