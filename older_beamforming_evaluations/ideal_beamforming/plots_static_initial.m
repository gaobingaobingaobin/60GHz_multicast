close all;
%clear all;
clc;

%THIS IS THE COMPLETE SCRIPT OF ALL THE PLOTS I NEED TO ANALYZE THE STATIC
%USER CASE

%load('ideal_beamforming_static_initial_results.mat');

t_conversion = 1000; %seconds to milliseconds


cc = hsv(N_T);
legend_K = eval(['{' sprintf('''Level = %d'' ',1:1:N_T) '}']);
legend_T = eval(['{' sprintf('''Time Cycle = %d'' ',T_cycles) '}']);
legend_BT= {'EXHAUSTIVE','RANDOM SELECTION','STRONGEST FIRST','WEAKEST FIRST','MINIMUM TRAINING','FINEST ALL'};

%% OVERHEAD ANALYSIS

%STATISTICS ACROSS THE DISTRIBUTIONS
training_overhead_stat = median(training_overhead,3);
feedback_overhead_stat = median(feedback_overhead,3);
total_overhead_stat = median(total_overhead,3);

%TRAINING BEACON OVERHEAD IN ABSOLUTE
figure;
cc = hsv(N_beam_tech);
for b_t=1:1:N_beam_tech
     h = plot(Nusers,t_conversion*training_overhead_stat(:,b_t),'color',cc(b_t,:));
     hold all;
end
title('Training Beacon Overhead in Absolute Sense');
xlabel('No. of users ---->');
ylabel('Milliseconds');
legend(legend_BT);
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');

%FEEDBACK OVERHEAD IN ABSOLUTE
figure;
for b_t=1:1:N_T
     h = plot(Nusers,t_conversion*feedback_overhead_stat(:,b_t),'color',cc(b_t,:));
     hold all;
end
title('Feedback Overhead in Absolute Sense');
xlabel('No. of users ---->');
ylabel('Milliseconds');
legend(legend_BT);
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');

%TOTAL OVERHEAD IN ABSOLUTE
figure;
for b_t=1:1:N_T
     h = plot(Nusers,t_conversion*total_overhead_stat(:,b_t),'color',cc(b_t,:));
     hold all;
end
title('Total Training Overhead in Absolute Sense');
xlabel('No. of users ---->');
ylabel('Milliseconds');
legend(legend_BT);
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');


% TOTAL OVERHEAD  RELATIVE TO TIME CYCLE
for t=1:1:max(size(T_cycles))
    figure;
    for b_t=1:1:N_beam_tech
        h = plot(Nusers,100*total_overhead_stat(:,b_t)/T_cycles(t),'color',cc(b_t,:));
        hold all;
    end
    title(['Total Overhead relative to Time Cycle = ' num2str(T_cycles(t))]);
    xlabel('No. of users ---->');
    ylabel('Percentage --->');
    legend(legend_BT);
    set(gca,'FontSize',20,'fontWeight','bold');
    set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
end


% DELAY PER SWEEP ANALYSIS
delay_per_sweep_stat = median(delay_per_sweep,3);
dd = hsv(N_beam_tech);

figure;
for b_t = 1:1:N_beam_tech
    h = plot(Nusers,t_conversion*L_max*delay_per_sweep_stat(:,b_t),'color',dd(b_t,:));
    hold all;
end
title('Delay Per Sweep for Max Packet Size');
xlabel('No. of users ---->');
ylabel('Milliseconds --->');
legend(legend_BT);
set(gca,'FontSize',20,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');



%% THROUGHPUT PER CYCLE ANALYSIS

% THROUGHPUT PER CYCLE PER USER
throughput_pc_pu_stat = median(throughput_per_cycle_per_user,4);

for t=1:1:max(size(T_cycles))
    figure;
    for b_t=1:1:N_beam_tech
        h = plot(Nusers,throughput_pc_pu_stat(:,t,b_t),'color',cc(b_t,:));
        hold all;
    end
    title(['Per-User Throughput with Time Cycle = ' num2str(T_cycles(t))]);
    xlabel('No. of users ---->');
    ylabel('Bits --->');
    legend(legend_BT);
    set(gca,'FontSize',20,'fontWeight','bold');
    set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
end

% THROUGHPUT PER CYCLE 
throughput_pc_stat = median(throughput_per_cycle,4);

for t=1:1:max(size(T_cycles))
    figure;
    for b_t=1:1:N_beam_tech
        h = plot(Nusers,throughput_pc_stat(:,t,b_t),'color',cc(b_t,:));
        hold all;
    end
    title(['Total Throughput with Time Cycle = ' num2str(T_cycles(t))]);
    xlabel('No. of users ---->');
    ylabel('Bits --->');
    legend(legend_BT);
    set(gca,'FontSize',20,'fontWeight','bold');
    set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
end
