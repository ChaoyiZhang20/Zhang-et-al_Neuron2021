function [] = errorbar_revised(t, mean, std)
    figure
    plot(t, mean, 'k');
    set(gcf, 'color', 'white');
    hold on
    y1 = mean+std;
    y2 = mean-std;
    y = [y1, fliplr(y2)];
    x = [t, fliplr(t)];
    fill(x, y, 'r', 'FaceAlpha', 0.3);
end