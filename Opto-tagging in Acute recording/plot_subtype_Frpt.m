% plot Fr and pt-width

figure
scatter(pt_width, fr, 40, [0.8 0.8 0.8],  'filled')
hold on
scatter(pt_width(idx_subtype{1}.idx),fr(idx_subtype{1}.idx),  40, [0.92 0.56 0.33],  'filled')
hold on
scatter(pt_width(idx_subtype{2}.idx),fr(idx_subtype{2}.idx),  40, [0.25 0.41 0.88],  'filled')
hold on
scatter(pt_width(idx_subtype{3}.idx),fr(idx_subtype{3}.idx),  40, [1 0 1],  'filled');
hold on
scatter(pt_width(idx_subtype{4}.idx),fr(idx_subtype{4}.idx),  60, [0 0 0], 'filled')
h_legend=legend(['No Response (n = ', num2str(length(idx_include) - length(idx_subtype{1}.idx) - length(idx_subtype{2}.idx)-length(idx_subtype{3}.idx)), ')'], ...
    ['Inh(n = ', num2str(length(idx_subtype{1}.idx)), ')'], ...
    ['Act(n = ', num2str(length(idx_subtype{2}.idx)), ')'], ...
    ['Inh-Act (n = ', num2str(length(idx_subtype{3}.idx)), ')'], ...
    ['Delay-Act (n = ', num2str(length(idx_subtype{4}.idx)), ')']);
xlim([0,800])

set(gca, 'Position',  [0.1, 0.1, 0.4, 0.6]);
set(gca, 'LineWidth', 1)
set(gca, 'FontSize', 10)
set(h_legend, 'FontSize', 10)

