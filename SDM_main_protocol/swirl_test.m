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
% 1 - TRIPTI DOT | 3 - ONLY FINEST | 4 - EXHAUSTIVE

N_beam_tech = 4; %Beam group generation techniques
% 1 - EXH - EXH, 2 - swirl based on EXH, 3 - swirl based on TRIPTI
% 4 - Only Finest Beam

N_tput_tech = 4;
% 1 - EXH - EXH, 2 - swirl based on EXH, 3 - swirl based on TRIPTI
% 4 - Only Finest Beam

Niters = 10;

%Storing the results 
training_overhead = zeros(Nclient_locs,N_train_tech,Niters);
time_per_sweep = zeros(Nclient_locs,N_beam_tech,Niters);
tput_per_cycle = zeros(Nclient_locs,N_tput_tech,Niters);

elapsed_time = zeros(Nclient_locs,N_beam_tech,Niters);

for N_u= 10
    
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
         
%          %BASIC CODEBOOK TREE ASCENDING ORDER TRAVERSAL
%          [RX_measure_basic_aot, Beam_index_basic_aot, tr_oh_basic_aot] = training_period_basic_cb_aot(client_spec,cb_id);
%          training_overhead(N_u,1,distr) = tr_oh_basic_aot;
         
         %EXHAUSTIVE TRAINING
         [RX_measure_exh, Beam_index_exh,tr_oh_exh] = training_period_exhaustive(client_spec,cb_id);
         training_overhead(N_u,3,distr) = tr_oh_exh;
         

         %swirl with Exh
         tic;
         [d_s_swirl_exh] = beam_gen_swirl(RX_measure_exh, Beam_index_exh);
         elapsed_time(N_u,2,distr) = toc;
         time_per_sweep(N_u,2,distr) = d_s_swirl_exh;


    end
end