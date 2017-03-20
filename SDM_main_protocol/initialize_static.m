% if(exist('global_params_incr.mat','file')==2)
%     delete global_params_incr.mat;
% end

%% ALL INITIAL PARAMETERS TO BE USED THROUGHOUT THE SIMULATION

%% ANTENNA PARAMETERS
% M_T = 8;
% N_br = 2; %Number of branches at each node of codebook tree
% N_T = floor(log2(M_T)/log2(N_br));
lambda = 0.005; %metres

theta_loc_range = 2*pi;

% Loading the Sub-spread angle optimized Codebook vectors 
load('measures_and_trees_map.mat');

Nap_bw = 5;

%% NETWORK SETUP 
d_min = 1; %Minimum distance from AP
d_max = 10;%0.5*length*sqrt(2); %AP is located at center of room
                            %Farthest distance is half diagonal                        
                            
%UNITS OF 10 MILLISECONDS
%stationary = 1000; %units of 1 milliseconds
Nslots = 1; %500 for LONG and 5000 for SHORT
L_max = 262143*8; %LONG data packet size
L_min = 8192*8; % SHORT Data Packet Size
%BF_freq_max = 16;
%time_gran = 0.001; %10 ms time intervals - Micro to 10 ms conversion
%Ntime_samples = T_cycle*Nslots;
%Nstatic = 2000;%ceil(pause/time_gran);

%% TRANSMIT POWER CALCULATION
%ASSUMPTION:
P_RX_min = -68;
P_RX_max = -47; %dBm at d_0 = 1 metre with finest TX beam pattern; -47 dBm when using OFDM-PHY and -53 dBm when using SC-PHY
P_TX = 32;% in mW  10 mW = 10 dBm; 32 mw= 15 dBm
PN= 7.9245e-11; %noise power (W)
BW = 2e9;
RX_offset = 10;

%% CHANNEL SETUP                            
alpha_coeff = 3;%Path loss coefficient in home network environment
lambda = 3*(10^8)/(60*(10^9));
d_0 = 1; %metres
PL_0 = 10*log10((4*pi/lambda)^2*d_0);
phy_mode = 'SC-PHY'; %SC-PHY, OFDM-PHY, LP-SC-PHY 

%% Timing Related Parameters and SSW Frame duration Calculation
%All values in microseconds 

SSW_fr_len = 33;%26640/(360*Nsectors) -> Nsectors = 1, Kumail's %T_stf_cp + T_ce_cp + ((11*8) + ((length-6)*8) + (N_cw*168))*T_c*32;
SSW_FB_len = 20;%19.2;
% FSS = 2;
% BF_refined_per_sector = aControlPreamble + aAirPropTime + ((FSS-1)*SBIFS) + (FSS*SSW_fr_len);
% BF_refined_per_sector = BF_refined_per_sector + MBIFS + SSW_FB_len ...
%     + SBIFS + SSW_FB_len + SBIFS + SSW_FB_len + SBIFS;

T_tr_pkt = (SSW_fr_len)*1e-3;
T_tr_level_offset = 0;%145.31*1e-3;
T_fb_pkt = (SSW_FB_len)*1e-3;

%% DATA RATE CALCULATION HASH MAPS FOR DIFFERENT PHY MODES

%MCS INDEX 
 %MCS 0 = CONTROL PHY
 %MCS 1-12 = SC PHY
 %MCS 13-24 = OFDM PHY
 %MCS 25-31 = LOW-POWER SC PHY
 
%RECEIVED POWER TO MCS MAP FOR SC-PHY
sense_thresh_SC = [-68,-66,-65,-64,-62,-63,-62,-61,-59,-55,-54,-53];
mcsIndex_SC = [1,2,3,4,5,6,7,8,9,10,11,12];
mcsMap_SC = containers.Map(sense_thresh_SC,mcsIndex_SC);

%RECEIVED POWER TO MCS FOR OFDM-PHY
sense_thresh_OFDM = [-66,-64,-63,-62,-60,-58,-56,-54,-53,-51,-49,-47];
mcsIndex_OFDM = [13,14,15,16,17,18,19,20,21,22,23,24];
mcsMap_OFDM = containers.Map(sense_thresh_OFDM,mcsIndex_OFDM);

%RECEIVED POWER TO MCS FOR LOW POWER SC-PHY
sense_thresh_LP_SC = [-64,-60,-57];
mcsIndex_LP_SC = [25,26,27];
mcsMap_LP_SC = containers.Map(sense_thresh_LP_SC,mcsIndex_LP_SC);

%MCS INDEX TO DATA RATE MAP in Mbps
mcsIndex = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27];
rates = [27.5,385,770,962.5,1155,1251.5,1540,1925,2310,2502.5,3080,3850,4620,693,866.25,1386,1732.5,2079,2772,3465,4158,4504.5,5197.5,6237,6756.75,626,834,1112]*1e3; % Bits/millisecond
mcsRateMap = containers.Map(mcsIndex,rates);

control_rate = min(rates);

%save global_params_incr.mat;      