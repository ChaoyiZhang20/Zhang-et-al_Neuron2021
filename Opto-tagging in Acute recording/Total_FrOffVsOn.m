x = mean(psth_mean(:, 500:1000),2);
y = mean(psth_mean(:, 1000:1500),2);

figure
p1 = scatter(x, y, 10, [0.8 0.8 0.8],  'LineWidth', 2);
hold on
p2 = scatter(x(idx_ws_include), y(idx_ws_include), 10, [1 0 0],  'LineWidth', 2);
hold on
p3 = scatter(x(idx_NS), y(idx_NS), 10, [0 0 1],  'LineWidth', 2);
hold on
p4 = scatter(x(idx_fs), y(idx_fs), 10, [0 0 0], 'o', 'LineWidth', 1.5);
hold on
p5 = scatter(x(idx_tag),y(idx_tag),  10, [0 1 0],  'filled');
hold on
p6 = plot(0:max(x), 0:max(x), 'k--', 'LineWidth', 1.5);
xlim([0 max(y)])
ylim([0 max(y)])
xlabel('Light Off')
ylabel('Light On')
h_legend = legend([p1 p2 p3 p4], ...
    {['No Response (n = ', num2str(length(fr) - length(idx_act) - length(idx_inb)), ')'], ...
    ['Activated (n = ', num2str(length(idx_act)), ')'], ...
    ['Inhibited (n = ', num2str(length(idx_inb)), ')'], ...
    ['FSI (n = ', num2str(length(idx_fs)), ')']});

set(gca, 'Position',  [0.1, 0.1, 0.4, 0.6]);
set(gca, 'LineWidth', 1)
set(gca, 'FontSize', 10)
set(h_legend, 'FontSize', 10)


% plot WS pie chart
activation= length(idx_ws_include_act);
inhibition= length(idx_ws_include_inb)
nochange=(size(idx_ws_include,1))-activation - inhibition

x=[ nochange,activation,inhibition,];
figure
pie(x)

legend(['No Response (n = ', num2str(nochange), ')'], ...
    ['Activated (n = ', num2str(activation), ')'], ...
    ['Inhibited (n = ',num2str(inhibition), ')']);

% plot NS piechart

activation= length(idx_ns_include_act);
inhibition= length(idx_ns_include_inb)
nochange=(size(idx_ns_include,1))-activation - inhibition

x=[ nochange,activation,inhibition,];
figure
pie(x)

legend(['No Response (n = ', num2str(nochange), ')'], ...
    ['Activated (n = ', num2str(activation), ')'], ...
    ['Inhibited (n = ',num2str(inhibition), ')']);

% plot FS piechart

activation= length(idx_fs_include_act);
inhibition= length(idx_fs_include_inb)
nochange=(size(idx_fs_include,1))-activation - inhibition

x=[ nochange,activation,inhibition,];
figure
pie(x)
