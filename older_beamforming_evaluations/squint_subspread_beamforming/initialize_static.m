if(exist('global_params_incr.mat','file')==2)
    delete global_params_incr.mat;
end

%% ALL INITIAL PARAMETERS TO BE USED THROUGHOUT THE SIMULATION

Niter =  1000; %No. of iterations of random placement

%% ANTENNA PARAMETERS
lambda = 0.005;
d = lambda/2;
M = 8; %M_T = M_R = M
N_B = 4;
K = floor(log(M)/log(N_B));
th_loc_range = pi;

% Loading the Sub-spread angle optimized Codebook vectors 
load('subspread_optimized_codebook.mat');


%% NETWORK SETUP 
d_min = 1; %Minimum distance from AP
d_max = 10;%0.5*length*sqrt(2); %AP is located at center of room
                            %Farthest distance is half diagonal
theta_loc_range = pi;                         
                            
%UNITS OF 10 MILLISECONDS
%stationary = 1000; %units of 1 milliseconds
T_cycle = 10*1e-3;%[10 25 50 100]; %units of 1ms; 100 for LONG and 20  for SHORT
Nslots = 1; %500 for LONG and 5000 for SHORT
L_max = 262143*8; %LONG data packet size
L_min = 8192*8; % SHORT Data Packet Size
%BF_freq_max = 16;
%time_gran = 0.001; %10 ms time intervals - Micro to 10 ms conversion
%Ntime_samples = T_cycle*Nslots;
%Nstatic = 2000;%ceil(pause/time_gran);

%% TRANSMIT POWER CALCULATION
%ASSUMPTION:
P_RX_min = -78;
P_RX_max = -47; %dBm at d_0 = 1 metre with finest TX beam pattern; -47 dBm when using OFDM-PHY and -53 dBm when using SC-PHY
P_TX = 10;% in mW  10 mW = 10 dBm; 32 mw= 15 dBm
PN= 7.9245e-11; %noise power (W)
BW = 2e9;

%% CHANNEL SETUP                            
alpha_coeff = 3;%Path loss coefficient in home network environment
lambda = 3*(10^8)/(60*(10^9));
d_0 = 1; %metres
PL_0 = 10*log10((4*pi/lambda)^2*d_0);
phy_mode = 'OFDM-PHY'; %SC-PHY, OFDM-PHY, LP-SC-PHY 

%% Timing Related Parameters and SSW Frame duration Calculation
%All values in microseconds 

SBIFS = 1;
aSIFS = 3;
LBIFS = 6*aSIFS;
MBIFS = 3*aSIFS;
aAirPropTime = 0.1;
T_stf = 1.236;
T_ce = 0.655;
T_c = 0.57*0.001;
T_header = 0.242; %For OFDM-PHY
%T_header = 0.582;%For SC-PHY
T_stf_cp = 3.636;
T_ce_cp = 0.655;
T_sym = 0.242;
length = 120;
L_cwd = 168;
aDataPreamble = 1.891;
aControlPreamble = 4.291;

N_cw = 1 + ceil((length-6)*8/L_cwd);
SSW_fr_len = 74;%26640/(360*Nsectors) -> Nsectors = 1, Kumail's %T_stf_cp + T_ce_cp + ((11*8) + ((length-6)*8) + (N_cw*168))*T_c*32;
SSW_FB_len = 19;
% FSS = 2;
% BF_refined_per_sector = aControlPreamble + aAirPropTime + ((FSS-1)*SBIFS) + (FSS*SSW_fr_len);
% BF_refined_per_sector = BF_refined_per_sector + MBIFS + SSW_FB_len ...
%     + SBIFS + SSW_FB_len + SBIFS + SSW_FB_len + SBIFS;

T_tr_pkt = (SSW_fr_len + SBIFS)*1e-6;
T_tr_level_offset = 145.31*1e-6;
T_fb_pkt = (SSW_FB_len + SBIFS)*1e-6;

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
rates = [27.5,385,770,962.5,1155,1251.5,1540,1925,2310,2502.5,3080,3850,4620,693,866.25,1386,1732.5,2079,2772,3465,4158,4504.5,5197.5,6237,6756.75,626,834,1112]*1e6; % Bits/millisecond
mcsRateMap = containers.Map(mcsIndex,rates);

control_rate = min(rates);

save global_params_incr.mat;      