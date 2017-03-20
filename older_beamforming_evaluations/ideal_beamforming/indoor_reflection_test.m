clear all;
close all;
clc;

addpath('../tree_matlab/');
addpath('../export_fig/');

load global_params_incr.mat;

N_T = 3;

room_size = [6;8]; %Breadth x Length
L = room_size(2);
B = room_size(1);
AP_loc = [L/2; B/2];
client_loc(1) = B*rand
client_loc(2) = L*rand
b_R = 2*pi*(20/360);
Nang = 100;

RX_training_cw = NaN(N_T,m_t(N_T),Nang);
NLOS_indicator_cw = -1*ones(N_T,m_t(N_T),Nang);
NLOS_indicator_ang = -1*ones(N_T,Nang);
RX_max_ang = NaN(N_T,Nang);

for q=1:1:N_T
    q
    for ang=1:1:Nang
        angle = ((ang-1)*theta_loc_range/Nang);
        for v=1:1:m_t(q)
            RX_measure_los = RX_LOS(AP_loc, w_or(v,q), b_T(q), client_loc,angle, b_R);
            RX_measure_nlos = RX_NLOS(AP_loc,w_or(v,q), b_T(q),client_loc,angle,b_R,room_size); 
            RX_training_cw(q,v,ang) = max(RX_measure_los,RX_measure_nlos);
            if(RX_training_cw(q,v,ang) == RX_measure_nlos)
                NLOS_indicator_cw(q,v,ang) = 1;
            end
        end
        [RX_max_ang(q,ang),ind] = max(squeeze(RX_training_cw(q,:,ang)));
        if(NLOS_indicator_cw(q,ind,ang) == 1)
            NLOS_indicator_ang(q,ang) = 1;
        end
    end
end

% Received Power Plots for Each Codeword in Each Codebook level
% Each line in each plot represents the Codeword
% Each point on X-axis represents the Client's receive antenna orientation
angles = (0:1:Nang-1)* theta_loc_range/Nang;
%cc = hsv(N_br_max);
cc = hsv(N_T);
legend_K = eval(['{' sprintf('''Level = %d'' ',1:1:N_T) '}']);

figure;

subplot(2,1,1);
for q = 1:1:N_T
    %figure
    %for v=1:1:m_t(q)
        %h = plot(angles,squeeze(RX_training(q,v,:)),'color',cc(v,:));
        h = plot(angles,squeeze(max(P_RX_min,RX_max_ang(q,:))),'color',cc(q,:));
        %h = plot(angles,squeeze(RX_max_ang(q,:)),'color',cc(q,:));
        hold all;
    %end
    %title(['CODEWORD POWER MEASURE FOR Codebook Level = ' num2str(q)]);
end
title('PRIMARY CODEWORD POWER MEASURE');
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
legend(legend_K);
subplot(2,1,2);
for q = 1:1:N_T
    %figure
    %for v=1:1:m_t(q)
        %h = plot(angles,squeeze(RX_training(q,v,:)),'color',cc(v,:));
        h = plot(angles,squeeze(NLOS_indicator_ang(q,:)),'color',cc(q,:));
        ylim([-2 2]);
        hold all;
    %end
    %title(['CODEWORD POWER MEASURE FOR Codebook Level = ' num2str(q)]);
end
title('NON LINE OF SIGHT INDICATOR');
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
legend(legend_K);