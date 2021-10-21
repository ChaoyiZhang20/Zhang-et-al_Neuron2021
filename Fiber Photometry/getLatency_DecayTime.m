% clc; clear;
% close all;
x = b;
t_decay = zeros(size(x, 1), 1);
t_pks = zeros(size(x, 1), 1);
t1 = zeros(size(x, 1), 1);
t2 = zeros(size(x, 1), 1);
t_rise = zeros(size(x, 1), 1);
psth_pre = 100;
psth_post = 600;

for i = 1 : size(x, 1)
    try
        [amp_pks, t_pks(i)] = max(x(i, psth_pre:psth_post));
        if amp_pks <=1.96
            t_decay(i) = NaN;
            t_rise(i)= NaN
            continue
        end
        t1(i) = find(x(i, 1:psth_pre+t_pks(i)) <= 1.96, 1, 'last');
        t_rise(i)=(t1(i)-300)/100
        t2(i) = find(x(i, psth_pre+t_pks(i):end) <= 1.96, 1, 'first');
        t_pks(i)=t_pks(i) + psth_pre
        t_decay(i) = (t2(i) + t_pks(i) - 300)/100;
    catch
        t_decay(i) = 4;
    end
end
t_decay_final=t_decay(~isnan(t_decay))
t_rise_final=t_rise(~isnan(t_rise))