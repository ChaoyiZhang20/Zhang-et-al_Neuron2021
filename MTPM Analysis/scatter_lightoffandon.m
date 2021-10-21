idx = find(p2 < 0.05)
a = mean(pks_td_pre, 2);
b = mean(pks_td_on, 2);
figure
plot(a, b,'.','color',[0.8 0.8 0.8],'markersize',20);
hold on
plot(a(idx), b(idx), '.', 'color',[1 0 1],'markersize',20)
hold on
plot(0:5, 0:5)
xlim([0 2.5])
ylim([0 2.5])
axis square


idx = find(p1 < 0.05)
c = mean(auc_td_pre, 2);
d = mean(auc_td_on, 2);
figure

plot(c, d,'.','color',[0.8 0.8 0.8],'markersize',20);
hold on
plot(c(idx), d(idx), '.', 'color',[1 0 1],'markersize',20)
hold on
plot(0:2, 0:2)
xlim([0 1.5])
ylim([0 1.5])
axis square