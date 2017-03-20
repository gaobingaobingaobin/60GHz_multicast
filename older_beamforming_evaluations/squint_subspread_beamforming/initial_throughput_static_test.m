clear all;
close all;
clc;

% THIS SCRIPT IS FOR THROUGHPUT TEST OF STOPPING TRAINING AT
%DIFFERENT CODEBOOK LEVELS FOR VARYING NUMBER OF USERS

initialize_static;

%Simulation Parameters
Nusers = [1 2 4:4:16]; %Number of users in the network
T_cycles = [10 50 100]*1e-3; %Length of one complete time cycle in milliseconds
N_beam_tech = 4; %Beam group generation techniques
%1 - EXHAUSTIVE SEARCH, 2 - RANDOM SELECTION, 3 - BEST USER, 4 - Weakest
%First

N_distr = 10; %Number of random distributions of users around the AP for a given number of users

%Storing the results 
delay_per_sweep = zeros(max(size(Nusers)),K,N_beam_tech,N_distr);
throughput_per_cycle = zeros(max(size(Nusers)),max(size(T_cycles)),K,N_beam_tech,N_distr);
throughput_per_cycle_per_user = zeros(max(size(Nusers)),max(size(T_cycles)),K,N_beam_tech,N_distr);
training_overhead = zeros(max(size(Nusers)),K,N_distr);
feedback_overhead = zeros(max(size(Nusers)),K,N_distr);
total_overhead = zeros(max(size(Nusers)),K,N_distr);

for u=1:1:max(size(Nusers))
    N_u = Nusers(u)
    
    for distr=1:1:N_distr
        distr
        temp = rand(N_u,2);
        user_loc(1:N_u,1) = d_min + ((d_max-d_min)*temp(:,1));
        user_loc(1:N_u,2) = (-1*theta_loc_range/2) + (temp(:,2)*theta_loc_range);
            
         %TRAINING PERIOD
         %Here training happens till K levels
         %Tree structure, so if a code (sector) has no reply of minimum
         %signal strength from any user then it's children/ descendants are not
         %considered for further training
         %At each codebook level, the User reports the highest
         %signal strength it obtained
        [RX_measure_report, RX_log_measure_report, Beam_index_report, t_tr_o, t_fb_o] = training_period(user_loc,K-1);
        
        training_overhead(u,:,distr) = t_tr_o;
        feedback_overhead(u,:,distr) = t_fb_o;
        t_total_o = t_tr_o + t_fb_o;
        total_overhead(u,:,distr) = t_total_o;

         for k=0:1:K-1
             %EXHAUSTIVE SEARCH
             beam_tech = 1;
             [d_s] = beam_gen_exhaustive(RX_measure_report, RX_log_measure_report, Beam_index_report,k);   
             delay_per_sweep(u,k+1,1,distr) = d_s;
                  
             %RANDOM SELECTION
             beam_tech = 2;
             [d_s] = beam_gen_random_select(RX_measure_report, RX_log_measure_report, Beam_index_report, k);
             delay_per_sweep(u,k+1,2,distr) = d_s;
                  
             %STRONGEST FIRST
             beam_tech = 3;
             [d_s] = beam_gen_strongest_first(RX_measure_report, RX_log_measure_report, Beam_index_report,k);
             delay_per_sweep(u,k+1,3,distr) = d_s;
                 
             %WEAKEST FIRST
             beam_tech = 4;
             [d_s] = beam_gen_weakest_first(RX_measure_report, RX_log_measure_report, Beam_index_report,k);
             delay_per_sweep(u,k+1,4,distr) = d_s;
             
             for t=1:1:max(size(T_cycles))
                 T_cycle = T_cycles(t);
                 for b_t = 1:1:N_beam_tech
                     throughput_per_cycle_per_user(u,t,k+1,b_t,distr) = ((T_cycle - t_total_o(k+1))/delay_per_sweep(u,k+1,b_t,distr));
                     throughput_per_cycle(u,t,k+1,b_t,distr) = throughput_per_cycle_per_user(u,t,k+1,b_t,distr)*N_u;
                 end
             end
         end
    end
end

delay_per_sweep = squeeze(delay_per_sweep);
throughput_per_cycle = squeeze(throughput_per_cycle);
throughput_per_cycle_per_user = squeeze(throughput_per_cycle_per_user);
training_overhead = squeeze(training_overhead);
feedback_overhead = squeeze(feedback_overhead);    
total_overhead = squeeze(total_overhead);

save('results_all_beam_tech_initial_static_Shannon.mat');