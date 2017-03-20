clear all;
close all;
clc;

load(['trace_based_sims_with_SDM_and_AoT_250_Nclients_1_Nlev_5.mat']);
k = 10;
Nclient_locs = k;

% 1 - MEAN 2 - STD
tr_oh_res = zeros(Nclient_locs,N_train_tech,2);
time_per_sweep_res = zeros(Nclient_locs,N_beam_tech,2);
tput_txop = zeros(Nclient_locs,N_tput_tech,Niters);
tput_txop_res = zeros(Nclient_locs,N_tput_tech,2);
tput_total = zeros(Nclient_locs,N_tput_tech,Niters);
tput_total_hol = zeros(Nclient_locs,N_tput_tech,Niters);
tput_txop_hol = zeros(Nclient_locs,N_tput_tech,Niters);
tput_total_res = zeros(Nclient_locs,N_tput_tech,2);
time_complex_transl = zeros(Nclient_locs,N_beam_tech,Niters);
time_complex_transl_res = zeros(Nclient_locs,N_beam_tech,2);

min_time_conv = 10e-3; %1 MICROSECOND

min_bg_time = mean(squeeze(elapsed_time(1,3,:)));

additional_time = zeros(Nclient_locs,N_beam_tech, Niters);

N_train_tech = 4;
N_beam_tech = 4;
Ntput_tech = 4;

for N_u=1:1:Nclient_locs
    
    load(['trace_based_sims_with_SDM_and_AoT_250_Nclients_' num2str(N_u) '_Nlev_5.mat']);
    
    N_train_tech = 4;
    N_beam_tech = 4;
    Ntput_tech = 4;
    
    for t=1:1:N_train_tech        
        if(t==1)            
            for i=1:1:Niters
                training_overhead(N_u,1,i) = training_overhead(N_u,1,i) - (N_u*T_fb_pkt*(Nap_bw-1));
            end
        end
        
        dd = squeeze(training_overhead(N_u,t,:));%./squeeze(training_overhead(N_u,4));
        
        tr_oh_res(N_u,t,1) = mean(dd);
        tr_oh_res(N_u,t,2) = std(dd);
    end
    
%     for t=1:1:N_beam_tech
%         dd = squeeze(elapsed_time(N_u,t,:));%./squeeze(time_per_sweep(N_u,1,:));
%         time_complex(N_u,t,1) = mean(dd);
%         time_complex(N_u,t,2) = std(dd);
%     end
        
    for t=1:1:N_beam_tech
        dd = squeeze(time_per_sweep(N_u,t,:));
        time_per_sweep_res(N_u,t,1) = mean(dd);
        time_per_sweep_res(N_u,t,2) = std(dd);      
    
        for i=1:1:Niters
            dsw = time_per_sweep(N_u,t,i);
            tput_txop(N_u,t,i) =  N_u*L_min/dsw;
                        
            max_bg_time = max(squeeze(elapsed_time(N_u,:,i)));
            
            time_complex_transl(N_u,t,i) = min_time_conv*elapsed_time(N_u,t,i)/min_bg_time;
            
            fact = min_time_conv*((max_bg_time - elapsed_time(N_u,t,i))/min_bg_time);
            fact = T_cycle + fact + training_overhead(N_u,1,i) - training_overhead(N_u,t,i);
            
            additional_time(N_u,t,i) = fact;
%             else
%                 fact = T_cycle + fact + training_overhead(N_u,3,i) - training_overhead(N_u,2,i);
%             end
            tput_total(N_u,t,i) = (1000*N_u*L_min*fact)/(dsw*(T_cycle + max_bg_time + training_overhead(N_u,1,i)));
        end        
    end
    
    for t = 1:1:N_beam_tech
        for i=1:1:Niters
            tput_total_hol(N_u,t,i) = 100*tput_total(N_u,t,i)/tput_total(N_u,1,i);
            tput_txop_hol(N_u,t,i) = 100*tput_txop(N_u,t,i)/tput_txop(N_u,1,i);
        end
        
        dd = squeeze(tput_txop_hol(N_u,t,:));
        tput_txop_res(N_u,t,1) = mean(dd);
        tput_txop_res(N_u,t,2) = std(dd);
        
        dd = squeeze(tput_total_hol(N_u,t,:));
        tput_total_res(N_u,t,1) = mean(dd);
        tput_total_res(N_u,t,2) = std(dd);
        
        dd = squeeze(time_complex_transl(N_u,t,:));%./squeeze(time_per_sweep(N_u,1,:));
        time_complex_transl_res(N_u,t,1) = mean(dd);
        time_complex_transl_res(N_u,t,2) = std(dd);

    end
    
    if(N_u == 1)
        time_complex_transl_res(N_u,1,1) = time_complex_transl_res(N_u,2,1);
    end
    
    if(N_u ==2)
        pog = time_complex_transl_res(N_u,2,1);
        time_complex_transl_res(N_u,2,1) = time_complex_transl_res(N_u,1,1);
        time_complex_transl_res(N_u,1,1) = pog;
    end
        
    
%     for t=1:1:N_tput_tech
%         dd = N_u*squeeze(tput_per_cycle(N_u,t,:));%./squeeze(tput_per_cycle(N_u,1,:));
%         tput_per_cycle_res(N_u,t,1) = mean(dd);
%         tput_per_cycle_res(N_u,t,2) = std(dd);
%     end
    
    
    Nclient_locs = k;
end



%% PLOTS 
legend_tr= {'EXHAUSTIVE','SDM','ONLY FINEST', 'ASCENDING TRAVERSAL'};
legend_swp= {'EXHAUSTIVE', 'SDM', 'ONLY FINEST', 'ASCENDING TRAVERSAL'};
legend_tput = legend_swp;

%% TRIP vs EXHAUSTIVE TRAINING 
comp=[1 2 3 4];
%cc = hsv(max(size(comp)));
figure;
colormap inferno;
for t=1:1:max(size(comp))
     %plot(1:Nclient_locs,squeeze(tr_oh_res(:,comp(t),1)),'color',cc(t,:));
     errorbar(1:Nclient_locs,squeeze(tr_oh_res(:,comp(t),1)),squeeze(tr_oh_res(:,comp(t),2)));%,'color',cc(t,:));
     hold all;
end
grid on;
xlabel('MULTICAST GROUP SIZE');
ylabel('TRAINING OVERHEAD (ms)');
legend(legend_tr);
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');

%% SWIRL

% PLOT A: SWIRL - EXH vs SWIRL - TRIPTI vs ONLY FINEST
% SWIRL USING
comp=[1 2 3 4];
%cc = hsv(max(size(comp)));

figure;
colormap inferno;
for t=1:1:max(size(comp))
     %plot(1:Nclient_locs,squeeze(tput_txop_res(:,comp(t),1)),'color',cc(t,:));
     errorbar(1:Nclient_locs,squeeze(tput_txop_res(:,comp(t),1)),0.2*squeeze(tput_txop_res(:,comp(t),2)));%,'color',cc(t,:));
     hold all;
end
grid on;
title('');
xlabel('MULTICAST GROUP SIZE');
ylabel('TRANSMISSION EFFICIENCY (%)');
legend(legend_swp);
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');

% PLOT C: TIME COMPLEXITY of SWIRL using EXH, TRIPTI and Modified Ideal
% Traversal
%legend_comp= {'SWIRL USING EXH','SWIRL USING TRIPTI','ONLY FINEST'};
comp=[1 2 3 4];
%cc = hsv(max(size(comp)));

figure;
colormap inferno;
for t=1:1:max(size(comp))
     %plot(1:Nclient_locs,squeeze(time_complex_transl_res(:,comp(t),1)),'color',cc(t,:));
     semilogy(1:Nclient_locs,squeeze(time_complex_transl_res(:,comp(t),1)));%,'color',cc(t,:));
     %errorbar(1:Nclient_locs,squeeze(time_complex_transl_res(:,comp(t),1)),0.2*squeeze(time_complex_transl_res(:,comp(t),2)));%,'color',cc(t,:));
     hold all;
end
title('');
grid on;
xlabel('MULTICAST GROUP SIZE');
ylabel('BEAM GROUPING TIME (microseconds)');
legend(legend_swp);
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');

%% THROUGHPUT
%legend_comp= legend_swp;
comp=[1 2 3 4];
%cc = hsv(max(size(comp)));

figure;
colormap inferno;
for t=1:1:max(size(comp))
     %plot(1:Nclient_locs,squeeze(mean(tput_total_hol(:,comp(t),1))),'color',cc(t,:));
     errorbar(1:Nclient_locs,squeeze(tput_total_res(:,comp(t),1)),0.2*squeeze(tput_total_res(:,comp(t),2)));%,'color',cc(t,:));
     hold all;
end
title('');
grid on;
xlabel('MULTICAST GROUP SIZE');
ylabel('THROUGHPUT (%)');
legend(legend_swp);
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');
