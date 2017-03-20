%close all;
clear all;
clc;

load('measures_and_trees_map.mat');

client_loc = 8;
client_or = 1;
ap_bw = 3;
Ncirc_shift = 50;

% PLOTTING FOR A SINGLE CLIENT LOCATION, ZERO ORIENTATION AND DIFFERENT AP BEAMWIDTHS
% NORMALIZED POWER vs TX Orientation
legend_bw= {'80 DEGREE','40 DEGREE','20 DEGREE','10 DEGREE','5 DEGREE'};

cc = hsv(Nap_bw);
figure;
for t=1:1:Nap_bw
     kk = squeeze(rms_norm_pow(client_loc,client_or,t,:));
     kk = circshift(kk,Ncirc_shift);
     plot(set_ant_angle,kk,'color',cc(t,:));
     %errorbar(1:Nclient_locs,squeeze(tr_oh_res(:,t,1)),squeeze(tr_oh_res(:,t,2)),'color',cc(t,:));
     hold all;
end
grid on;
title(['Client Location = ' num2str(client_loc) ' Client Or = ' num2str(client_or)]);
xlabel('AP Orientation Angle (degrees) ---->');
ylabel('Normalized Power --->');
legend(legend_bw);
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');


%PLOTTING FOR A SINGLE CLIENT LOCATION, THREE DIFFERENT ORIENTATIONS AND 7
%DEGREE BEAMWIDTH
legend_or= {'0 DEGREE','60 DEGREE','-60 DEGREE'};

cc = hsv(Nclient_ors);
figure;
for t=1:1:Nclient_ors
     kk = squeeze(rms_norm_pow(client_loc,t,ap_bw,:));
     kk = circshift(kk,Ncirc_shift);
     plot(set_ant_angle,kk,'color',cc(t,:));
     %errorbar(1:Nclient_locs,squeeze(tr_oh_res(:,t,1)),squeeze(tr_oh_res(:,t,2)),'color',cc(t,:));
     hold all;
end
title(['Client Location = ' num2str(client_loc) ' AP BW = ' num2str(ap_bw)]);;
xlabel('AP Orientation Angle (degrees) ---->');
ylabel('Normalized Power --->');
legend(legend_or);
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');