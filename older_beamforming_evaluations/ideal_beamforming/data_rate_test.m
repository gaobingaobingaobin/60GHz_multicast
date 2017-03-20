clear all;
clc;

% THIS SCRIPT IS FOR OBTAINING RECEIVED POWER MAPS FOR DIFFERENT USER
% LOCATIONS AND DIFFERENT CODEBOOK LEVELS
%

initialize_static;

Ndist = 20;
Nang = 100;

P_T = 0.032; 
TX_location = [0,0];
PN=7.9245e-11; %noise power (W)
B = 2e9;

%Storing the results 
RX_measure = zeros(Ndist,Nang,N_T);

for q=1:1:N_T
    q
    for d=1:1:Ndist
        d
        dist = d_min + ((d-1)*(d_max-d_min)/Ndist);
        for ang=1:1:Nang
            angle = ((ang-1)*th_loc_range/Nang);
            
            G_beam = zeros(m_t(q),1);
            for v=1:1:m_t(q)
                beam_gain = 2*pi*eta/b_T(q);
                rx_dev = abs(angle - w_or(v,q));
                deviation_loss = 10^(1.2*((rx_dev/b_T(q))^2));
                G_beam(v) = beam_gain/deviation_loss;
            end
            G_beam_max = max(abs(G_beam));
            
            PL = 10^((PL_0 + (10*alpha_coeff*log10(dist/d_0)))/10);
            
            %RX_measure(d,ang,k+1) = P_TX + P_RX_max + (10*log10(G_beam_max^2)) - (10*alpha_coeff*log10(dist/d_min));
            RX_measure(d,ang,q) = P_T*(G_beam_max)/PL;
            RX_log_measure(d,ang,q) = RX_offset + (10*log10(RX_measure(d,ang,q)));
            Std_rate(d,ang,q) = DataRate(RX_log_measure(d,ang,q));
            Shannon_rate(d,ang,q) = DataRate_Shannon(RX_log_measure(d,ang,q));
        end
    end
end

kk = squeeze(Shannon_rate(:,1,:));
dd = squeeze(Std_rate(:,1,:));

range = d_min + ((0:1:Ndist-1)*(d_max-d_min)/Ndist);
cc=hsv(N_T);
legend_K = eval(['{' sprintf('''Level = %d'' ',1:1:N_T) '}']);

figure;
for q=1:1:N_T
    plot(range,mean(RX_log_measure(:,:,q),2),'color',cc(q,:));
    hold all;
end
title(['Received Power in dBm Min = ' num2str(d_min) ' Max = ' num2str(d_max)]);
legend(legend_K);

% figure;
% for q=1:1:N_T
%     plot(range,Shannon_rate(:,1,q),'color',cc(q,:));
%     hold all;
% end
% title('Shannon Rate');
% legend(legend_K);
    
figure;
for q=1:1:N_T
    plot(range,Std_rate(:,1,q),'color',cc(q,:));
    hold all;
end
title('802.11ad Rate');
legend(legend_K);

% % %SURF PLOTS
% for q=1:1:N_T
%     figure;
%     surf(squeeze(RX_log_measure(:,:,q)));
%     title([' Level = ' num2str(q)]);
% end

save(['data_rate_test.mat']);
