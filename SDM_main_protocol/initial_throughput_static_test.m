clear all;
close all;
clc;

% THIS SCRIPT IS FOR THROUGHPUT TEST OF STOPPING TRAINING AT
%DIFFERENT CODEBOOK LEVELS FOR VARYING NUMBER OF USERS

addpath('../tree_matlab/');
addpath('../export_fig/');
initialize_static;

%Simulation Parameters
T_cycle = [8.192]; %Length of one complete time cycle in milliseconds
Ncycles = max(size(T_cycle));
N_train_tech = 4;
% 1 - SDM DOT | 2 - ONLY FINEST | 3 - EXHAUSTIVE | 4 - Ascending Order
% Traversal

N_beam_tech = 4; %Beam group generation techniques
% 1 - EXH - EXH, 2 - SDM, 3 - Only Finest Beam, 4 - Ascending Order
% Traversal (AoT)

N_tput_tech = 4;
% 1- Exhaustive 2 - SDM 3 - Only Finest Beam 4 - AoT

Niters = 100;

%Storing the results 
training_overhead = zeros(Nclient_locs,N_train_tech,Niters);
time_per_sweep = zeros(Nclient_locs,N_beam_tech,Niters);
tput_per_cycle = zeros(Nclient_locs,N_tput_tech,Niters);

elapsed_time = zeros(Nclient_locs,N_beam_tech,Niters);

for N_u= 1:1:Nclient_locs
    
    N_u
    N_distr(N_u) = Ncodebooks*nchoosek(Nclient_locs,N_u)*(Nclient_ors^N_u);
    cl_sel = combnk(1:Nclient_locs,N_u);
    rand_sample = ceil(nchoosek(Nclient_locs,N_u)*rand(Niters,1));
        
    for distr=1:1:Niters
         distr
         client_spec = zeros(N_u,2);
         client_spec(:,1) = cl_sel(rand_sample(distr),:);
         client_spec(:,2) = ceil(Nclient_ors*rand(N_u,1));%3*ones(N_u,1)
         
         cb_id = ceil(Ncodebooks*rand);
        
         %% TRAINING PERIOD
         %XYZ PROTOCOL
%          [RX_measure_xyz, Beam_index_xyz, tr_oh_xyz] = training_period_xyz(client_spec,cb_id);
%          training_overhead(N_u,1) = training_overhead(N_u,1) + tr_oh_xyz;
         %Beam_index_xyz
         
         %SDM
         [RX_measure_SDM, Beam_index_SDM, tr_oh_SDM,RX_measure_full_SDM] = training_period_SDM(client_spec,cb_id);
         training_overhead(N_u,1,distr) = tr_oh_SDM;

         %ONLY FINEST TRAINING
         [RX_measure_only_finest, Beam_index_only_finest, tr_oh_only_finest] = training_period_only_finest(client_spec,cb_id);
         training_overhead(N_u,2,distr) = tr_oh_only_finest;
         %Beam_index_only_finest
         
         %EXHAUSTIVE TRAINING
         [RX_measure_exh, Beam_index_exh,tr_oh_exh,RX_measure_full_exh] = training_period_exhaustive(client_spec,cb_id);
         training_overhead(N_u,3,distr) = tr_oh_exh;
         
          %BASIC CODEBOOK TREE ASCENDING ORDER TRAVERSAL
          [RX_measure_aot, Beam_index_aot, tr_oh_aot] = training_period_aot_final(client_spec,cb_id);
          training_overhead(N_u,4,distr) = tr_oh_aot;
        
         
         %% BEAM GENERATION
         
%          %EXHAUSTIVE SEARCH based on EXH
%          tic;
%          [d_s_exh] = beam_gen_exhaustive(RX_measure_exh,Beam_index_exh,RX_measure_full_exh);
%          elapsed_time(N_u,1,distr) = toc;
%          time_per_sweep(N_u,1,distr) = d_s_exh;
%          d_s_exh

         %swirl with Exh
         tic;
         [d_s_swirl_exh] = beam_gen_swirl(RX_measure_exh,Beam_index_exh, RX_measure_full_exh);
         elapsed_time(N_u,1,distr) = toc;
         time_per_sweep(N_u,1,distr) = d_s_swirl_exh;
         %d_s_swirl_exh
         
          %swirl with TRIPTI
         tic;
         [d_s_swirl_tripti] = beam_gen_swirl(RX_measure_tripti, Beam_index_tripti,RX_measure_full_tripti);
         elapsed_time(N_u,2,distr) = toc;
         time_per_sweep(N_u,2,distr) = d_s_swirl_tripti;
         %d_s_swirl_tripti
         
         %Only Finest Beam Selection
         tic;
         [d_s_only_finest] = beam_gen_only_finest(RX_measure_only_finest, Beam_index_only_finest);
         elapsed_time(N_u,3,distr) = toc;
         time_per_sweep(N_u,3,distr) = d_s_only_finest;
         %d_s_only_finest


         %% THROUGHPUT CALCULATION
% 
%          %Exhaustive and Exhaustive
%          tput_per_cycle(N_u,1,distr) = L_min*(T_cycle - tr_oh_exh)/(d_s_exh*N_u);
         
         % EXH + swirl
         tput_per_cycle(N_u,1,distr) = L_min*(T_cycle - tr_oh_exh)/(d_s_swirl_exh*N_u);

%         TRIPTI + swirl
          tput_per_cycle(N_u,2,distr) = L_min*(T_cycle - tr_oh_tripti)/(d_s_swirl_tripti*N_u);

         % Only Finest
         tput_per_cycle(N_u,3,distr) = L_min*(T_cycle - tr_oh_only_finest)/d_s_only_finest;    

         save(['Results/trace_based_sims_with_tripti_dot_swirl_expanded_' num2str(Niters) '_Nclients_' num2str(N_u) '_Nlev_' num2str(Nap_bw) '.mat']); 
    end
end