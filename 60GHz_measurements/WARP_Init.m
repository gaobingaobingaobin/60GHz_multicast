%% WARP_Init.m
% Initializes all WARP parameters

disp('Initalizing the WARP platform ...');

%Load some global definitions (packet types, etc.)
warplab_defines

% Create Socket handles and intialize nodes
[socketHandles, packetNum] = warplab_initialize(2);

% Separate the socket handles for easier acces s
% The first socket handle is always the magic SYNC
% The rest of the handles are the handles to the WARP nodes
udp_Sync = socketHandles(1);
udp_node1 = socketHandles(2); % id for first board
udp_node2 = socketHandles(3); %id for second board

% Define WARPLab parameters. 
% For this experiment node 1 will be set as the transmitter and node 
% 2 will be set as the receiver (this is done later in the code), hence, 
% there is no need to define receive gains for node 1 and there is no
% need to define transmitter gains for node 2.
TxDelay = 50; % Number of noise samples per Rx capture. In [0:2^14]
TxLength = 2^14-1-TxDelay; % Length of transmission. In [0:2^14-1-TxDelay]
CarrierChannel = 12; % Channel in the 2.4 GHz band. In [1:14]
Node1_Radio4_TxGain_BB = 3; % Tx Baseband Gain. In [0:3]
Node1_Radio4_TxGain_RF = 40; % Tx RF Gain. In [0:63]

Node1_Radio4_RxGain_BB = 13; % Rx Baseband Gain. In [0:31]
Node1_Radio4_RxGain_RF = 1; % Rx RF Gain. In [1:3]  

TxMode = 1; % Transmission mode. In [0:1] 
            % 0: Single Transmission 
            % 1: Continuous Transmission. Tx board will continue 
            % transmitting the vector of samples until the user manually
            % disables the transmitter. 
            
% Node1_MGC_AGC_Select = 0;   % Set MGC_AGC_Select=1 to enable Automatic Gain Control (AGC). 
%                             % Set MGC_AGC_Select=0 to enable Manual Gain Control (MGC).
%                             % By default, the nodes are set to MGC. 
%                             
% Node2_MGC_AGC_Select = 0;   % Set MGC_AGC_Select=1 to enable Automatic Gain Control (AGC). 
%                             % Set MGC_AGC_Select=0 to enable Manual Gain Control (MGC).
%                             % By default, the nodes are set to MGC. 
                            
% The TxDelay, TxLength, and TxMode parameters need to be known at the transmitter;
% the receiver doesn't require knowledge of these parameters (the receiver
% will always capture 2^14 samples). For this exercise node 1 will be set as
% the transmitter (this is done later in the code). Since TxDelay, TxLength and
% TxMode are only required at the transmitter we download the TxDelay, TxLength and
% TxMode parameters only to the transmitter node (node 1).
%disp('write register')


% % The CarrierChannel parameter must be downloaded to all nodes  
% warplab_setRadioParameter(udp_node1,CARRIER_CHANNEL,CarrierChannel);
% warplab_setRadioParameter(udp_node2,CARRIER_CHANNEL,CarrierChannel);
% 
% warplab_setRadioParameter(udp_node1,RADIO4_TXGAINS,(Node1_Radio4_TxGain_RF + Node1_Radio4_TxGain_BB*2^16));
% warplab_setRadioParameter(udp_node2,RADIO4_RXGAINS,(Node1_Radio4_RxGain_BB + Node1_Radio4_RxGain_RF*2^16));
% warplab_setAGCParameter(udp_node1,MGC_AGC_SEL, Node1_MGC_AGC_Select);
% warplab_setAGCParameter(udp_node2,MGC_AGC_SEL, Node2_MGC_AGC_Select);

WARPReady = true;