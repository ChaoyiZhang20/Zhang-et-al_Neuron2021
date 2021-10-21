
PostT=4;
edges=[-1 -1:0.2:PostT PostT];
%% figure
figure
% subplot(5, 1, 1),
% histogram(Syn,edges,'FaceColor','r','EdgeAlpha',0.5);
% hold on
% plot([mean_Syn, mean_Syn],[0,8],'b-');
% grid on
subplot(5, 1, 1),
histogram(PYR_push,edges,'FaceColor',[1 0.4 0.4],'EdgeAlpha',0.5);
hold on

subplot(5, 1, 2),
histogram(PV_push,edges,'FaceColor','b','EdgeAlpha',0.5);
hold on

subplot(5, 1, 3),
histogram(VIP_push,edges,'FaceColor',[0 1 0.5],'EdgeAlpha',0.5);
hold on

subplot(5, 1, 4),
histogram(SOM_push,edges,'FaceColor',[1 0.7 0.4],'EdgeAlpha',0.5);
hold on
