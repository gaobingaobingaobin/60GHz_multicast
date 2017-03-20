clear all;
close all;
clc;

% THIS SCRIPT IS FOR THROUGHPUT TEST OF STOPPING TRAINING AT
%DIFFERENT CODEBOOK LEVELS FOR VARYING NUMBER OF USERS

addpath('../tree_matlab/');
addpath('../export_fig/');
run global_params_incr.mat;

%Simulation Parameters
Nusers = [1 2 4:2:12]; %Number of users in the network
T_cycles = [10 20 50]*1e-3; %Length of one complete time cycle in milliseconds
N_beam_tech = 6; %Beam group generation techniques
%1 - EXHAUSTIVE SEARCH, 2 - RANDOM SELECTION, 3 - BEST USER, 4 - Weakest
%First

N_distr = 100; %Number of random distributions of users around the AP for a given number of users

%Storing the results 
delay_per_sweep = zeros(max(size(Nusers)),N_beam_tech,N_distr);
throughput_per_cycle = zeros(max(size(Nusers)),max(size(T_cycles)),N_beam_tech,N_distr);
throughput_per_cycle_per_user = zeros(max(size(Nusers)),max(size(T_cycles)),N_beam_tech,N_distr);
training_overhead = zeros(max(size(Nusers)),N_beam_tech,N_distr);
feedback_overhead = zeros(max(size(Nusers)),N_beam_tech,N_distr);
total_overhead = zeros(max(size(Nusers)),N_beam_tech,N_distr);

for u=1:1:max(size(Nusers))
    N_u = Nusers(u)
    
    for distr=1:1:N_distr
        distr
        temp = rand(N_u,2);
        user_loc(1:N_u,1) = d_min + ((d_max-d_min)*temp(:,1));
        user_loc(1:N_u,2) = (temp(:,2)*theta_loc_range);
            
         %TRAINING PERIOD
         %Here training happens till K levels
         %Tree structure, so if a code (sector) has no reply of minimum
         %signal strength from any user then it's children/ descendants are not
         %considered for further training
         %At each codebook level, the User reports the highest
         %signal strength it obtained
        [RX_measure_report, RX_log_measure_report, Beam_index_report, t_tr_o, t_fb_o] = training_period_exhaustive(user_loc);

        t_total_o = t_fb_o + t_tr_o;
        
%         %EXHAUSTIVE SEARCH
%          beam_tech = 1;
%          [d_s] = beam_gen_exhaustive(RX_measure_report, RX_log_measure_report, Beam_index_report);
%          delay_per_sweep(u,1,distr) = d_s;
%          training_overhead(u,1,distr) = t_tr_o;
%          feedback_overhead(u,1,distr) = t_fb_o;
%          total_overhead(u,1,distr) = t_total_o;
% 
%          %RANDOM SELECTION
%          beam_tech = 2;
%          [d_s] = beam_gen_random_select(RX_measure_report, RX_log_measure_report, Beam_index_report);
%          delay_per_sweep(u,2,distr) = d_s;
%          training_overhead(u,2,distr) = t_tr_o;
%          feedback_overhead(u,2,distr) = t_fb_o;
%          total_overhead(u,2,distr) = t_total_o;
% 
%          %STRONGEST FIRST
%          beam_tech = 3;
%          [d_s] = beam_gen_strongest_first(RX_measure_report, RX_log_measure_report, Beam_index_report);
%          delay_per_sweep(u,3,distr) = d_s;
%          training_overhead(u,3,distr) = t_tr_o;
%          feedback_overhead(u,3,distr) = t_fb_o;
%          total_overhead(u,3,distr) = t_total_o;
% 
%          %WEAKEST FIRST
%          beam_tech = 4;
%          [d_s] = beam_gen_weakest_first(RX_measure_report, RX_log_measure_report, Beam_index_report);
%          delay_per_sweep(u,4,distr) = d_s;
%          training_overhead(u,4,distr) = t_tr_o;
%          feedback_overhead(u,4,distr) = t_fb_o;
%          total_overhead(u,4,distr) = t_total_o;
%          
%          % MINIMUM TRAINING PROTOCOL
%          beam_tech = 5;
%          [d_s, t_tr_o_mt, t_fb_o_mt] = beam_gen_minimum_training(RX_measure_report, RX_log_measure_report, Beam_index_report);
%          delay_per_sweep(u,5,distr) = d_s;
%          training_overhead(u,5,distr) = t_tr_o_mt;
%          feedback_overhead(u,5,distr) = t_fb_o_mt;
%          total_overhead(u,5,distr) = t_fb_o_mt + t_tr_o_mt;
%          
%          % FINEST BEAM PROTOCOL
%          beam_tech = 6;
%          [d_s, t_tr_o_fa, t_fb_o_fa] = beam_gen_finest_all(RX_measure_report, RX_log_measure_report, Beam_index_report);
%          delay_per_sweep(u,6,distr) = d_s;
%          training_overhead(u,6,distr) = t_tr_o_fa;
%          feedback_overhead(u,6,distr) = t_fb_o_fa;
%          total_overhead(u,6,distr) = t_fb_o_fa + t_tr_o_fa;
% 
%          for t=1:1:max(size(T_cycles))
%              T_cycle = T_cycles(t);
%              for b_t = 1:1:N_beam_tech
%                  throughput_per_cycle_per_user(u,t,b_t,distr) = ((T_cycle - total_overhead(u,b_t,distr))/delay_per_sweep(u,b_t,distr));
%                  throughput_per_cycle(u,t,b_t,distr) = throughput_per_cycle_per_user(u,t,b_t,distr)*N_u;
%              end
%          end
    end
    %save(['ideal_beamforming_static_initial_results.mat']);
end

% delay_per_sweep = squeeze(delay_per_sweep);
% throughput_per_cycle = squeeze(throughput_per_cycle);
% throughput_per_cycle_per_user = squeeze(throughput_per_cycle_per_user);
% training_overhead = squeeze(training_overhead);
% feedback_overhead = squeeze(feedback_overhead);    
% total_overhead = squeeze(total_overhead);
% 
% save(['ideal_beamforming_static_initial_results.mat']);