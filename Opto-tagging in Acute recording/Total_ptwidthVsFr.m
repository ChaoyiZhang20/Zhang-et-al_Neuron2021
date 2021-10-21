% plot Fr and pt-width


figure
scatter(pt_width(idx_include), fr(idx_include), 30, [0.8 0.8 0.8],  'filled')
hold on
scatter(pt_width(idx_act_include),fr(idx_act_include),  30, [248/255 182/255 43/255],  'filled')
hold on
scatter(pt_width(idx_inb_include),fr(idx_inb_include),  30, [41/255 157/255 208/255],  'filled')

h_legend=legend(['No Response (n = ', num2str(length(idx_include) - length(idx_act_include) - length(idx_inb_include)), ')'], ...
    ['Activated (n = ', num2str(length(idx_act_include)), ')'], ...
    ['Inhibited (n = ', num2str(length(idx_inb_include)), ')']) ;

xlim([0,800])

axis square
set(gca, 'Position',  [0.1, 0.1, 0.5, 0.5]);
set(gca, 'LineWidth', 1)
set(gca, 'FontSize', 10)
set(h_legend, 'FontSize', 10)




% Plot deltafr and PT width
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
mean_a=mean(a);
mean_b=mean(b)

deltafr=mean_b-mean_a

% idx_WS_include=intersect(idx_WS,idx_include)
% idx_NS_include=intersect(idx_NS,idx_include)

figure
% scatter(pt_width(idx_include), deltafr(idx_include), 20, [0.8 0.8 0.8],  'o', 'LineWidth', 1.5)
% hold on
scatter(pt_width(idx_ws_include),deltafr(idx_ws_include),  30, [0 0 1],  'filled')
hold on
scatter(pt_width(idx_ns_include),deltafr(idx_ns_include),  30, [201/255 160/255 99/255],  'filled')
hold on
scatter(pt_width(idx_tag),deltafr(idx_tag),  30, [131/255 182/255 66/255],  'filled');
hold on
scatter(pt_width(idx_fs_include),deltafr(idx_fs_include),  30, [1 0 0],  'filled')
h_legend=legend(['WS (n = ', num2str(length(idx_ws_include)), ')'], ...
    ['NS (n = ', num2str(length(idx_ns_include)), ')'], ...
    ['Tag (n = ', num2str(length(idx_tag)), ')'], ...
    ['FSI (n = ', num2str(length(idx_fs_include)), ')']);
xlim([0,800])

axis square
set(gca, 'Position',  [0.1, 0.1, 0.5, 0.5]);
set(gca, 'LineWidth', 1)
set(gca, 'FontSize', 10)
set(h_legend, 'FontSize', 10)

hold on
plot([0,800],[0,0],'k:')
ylim([-10,40])
