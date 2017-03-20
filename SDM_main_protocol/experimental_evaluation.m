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
% 1 - EXHAUSTIVE  | 2 - SDM | 3 - ONLY FINEST | 4 - Ascending Order
% Traversal (AoT)

N_beam_tech = 4; %Beam group generation techniques
% 1 - EXH - EXH, 2 - SDM, 3 - Only Finest Beam 4 - AOT

%Exhaustive Beam grouping means finding for each wide beam in the codebook tree, 
%Wide Beam Improvement ratio for
%every valid client subset assignment unlike SDM where the servable set is
%the unique client assignment to a beam

N_tput_tech = 4;
%  1 - EXH-EXH, 2 - SDM, 3 - Only Finest Beam 4 - Ascending Order Traversal

Niters = 250;

%Storing the results 
training_overhead = zeros(Nclient_locs,N_train_tech,Niters);
time_per_sweep = zeros(Nclient_locs,N_beam_tech,Niters);
tput_per_cycle = zeros(Nclient_locs,N_tput_tech,Niters);
elapsed_time = zeros(Nclient_locs,N_beam_tech,Niters);
Nbeams_levels = zeros(Nclient_locs,N_beam_tech,Nap_bw, Niters);

for N_u=1:1:8
    
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
        
                  
         %EXHAUSTIVE TRAINING
         [RX_measure_exh, Beam_index_exh,tr_oh_exh,RX_measure_full_exh] = training_period_exhaustive(client_spec,cb_id);
         training_overhead(N_u,1,distr) = tr_oh_exh;
        
         %SDM
         [RX_measure_SDM, Beam_index_SDM, tr_oh_SDM,RX_measure_full_SDM] = training_period_SDM(client_spec,cb_id);
         training_overhead(N_u,2,distr) = tr_oh_SDM;

         %ONLY FINEST TRAINING
         [RX_measure_only_finest, Beam_index_only_finest, tr_oh_only_finest] = training_period_only_finest(client_spec,cb_id);
         training_overhead(N_u,3,distr) = tr_oh_only_finest;
         %Beam_index_only_finest

         
         %BASIC CODEBOOK TREE ASCENDING ORDER TRAVERSAL
         [RX_measure_aot, Beam_index_aot, tr_oh_aot, RX_measure_full_aot] = training_period_aot_final(client_spec,cb_id);
         training_overhead(N_u,4,distr) = tr_oh_aot;
         
         %% BEAM GENERATION
         
%          %EXHAUSTIVE SEARCH based on EXH
%          tic;
%          [d_s_exh] = beam_gen_exhaustive(RX_measure_exh,Beam_index_exh,RX_measure_full_exh);
%          elapsed_time(N_u,1,distr) = toc;
%          time_per_sweep(N_u,1,distr) = d_s_exh;
%          d_s_exh

         %Exhaustive Beam grouping with Exhaustive Training
         tic;
         [d_s_exh_exh,Nbeams_lev_exh] = beam_gen_exhaustive_client_assign(RX_measure_exh,Beam_index_exh, RX_measure_full_exh);
         elapsed_time(N_u,1,distr) = toc;
         time_per_sweep(N_u,1,distr) = d_s_exh_exh;
         Nbeams_levels(N_u,1,:,distr) = Nbeams_lev_exh;
         %d_s_swirl_exh
         
         %SDM
         tic;
         [d_s_SDM, Nbeams_lev_SDM] = beam_gen_SDM(RX_measure_SDM, Beam_index_SDM,RX_measure_full_SDM);
         elapsed_time(N_u,2,distr) = toc;
         time_per_sweep(N_u,2,distr) = d_s_SDM;
         Nbeams_levels(N_u,2,:,distr) = Nbeams_lev_SDM;
         %d_s_swirl_tripti
         
         %Only Finest Beam Selection
         tic;
         [d_s_only_finest, Nbeams_lev_only_finest] = beam_gen_only_finest(RX_measure_only_finest, Beam_index_only_finest);
         elapsed_time(N_u,3,distr) = toc;
         time_per_sweep(N_u,3,distr) = d_s_only_finest;
         Nbeams_levels(N_u,3,:,distr) = Nbeams_lev_only_finest;
         %d_s_only_finest

         %Ascending Order Traversal (AoT)
         tic;
         [d_s_aot,Nbeams_lev_aot] = beam_gen_aot(RX_measure_aot, Beam_index_aot,RX_measure_full_aot);
         elapsed_time(N_u,4,distr) = toc;
         time_per_sweep(N_u,4,distr) = d_s_aot;
         Nbeams_levels(N_u,4,:,distr) = Nbeams_lev_aot;
         
         %% THROUGHPUT CALCULATION
% 
%          %Exhaustive and Exhaustive
%          tput_per_cycle(N_u,1,distr) = L_min*(T_cycle - tr_oh_exh)/(d_s_exh);
         
        % EXH + EXH
        tput_per_cycle(N_u,1,distr) = L_min*(T_cycle - tr_oh_exh)/(d_s_exh_exh);

        % SDM
        tput_per_cycle(N_u,2,distr) = L_min*(T_cycle - tr_oh_SDM)/(d_s_SDM);

        % Only Finest
        tput_per_cycle(N_u,3,distr) = L_min*(T_cycle - tr_oh_only_finest)/d_s_only_finest;    
        
        % AoT
        tput_per_cycle(N_u,4,distr) = L_min*(T_cycle - tr_oh_aot)/d_s_aot;

       save(['trace_based_sims_with_SDM_and_AoT_' num2str(Niters) '_Nclients_' num2str(N_u) '_Nlev_' num2str(Nap_bw) '.mat']); 
     end
end