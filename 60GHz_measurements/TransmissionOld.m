%% Transmission.m
% Performs one transmission of the experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Turn of warnings on obsolte functions
warning('off','comm:obsolete:rcosine');
warning('off','comm:obsolete:rcosflt');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Transmitter Baseband Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the number of Symbols to transmit
% The Warplab transmit buffer can store a maximum of 2^14 samples, for each
% symbol nOS samples are required. nOS is the oversampling factor that is
% determined by the selected sampling rate. nPad, is the number of zero
% padding samples at the end of transmission
TxDelay = 50;
nOS		= 40e6 ./ par.fsamp;
nSym	= floor((2^13 - 2*TxDelay) ./ nOS) - length(preamble)*par.nPreamble; 
TxLength = (nSym + length(preamble)*par.nPreamble) * nOS + TxDelay;

% Create some random data
payload_tx		= randi([0, par.modIndex - 1], [nSym, 1]);

% Modulate the data using either PSK or QAM
if strcmp(par.modType, 'PSK')
	symbols_tx = dpskmod(payload_tx, par.modIndex);
elseif  strcmp(par.modType, 'QAM')
	symbols_tx = qammod(payload_tx, par.modIndex);
	symbols_tx = symbols_tx ./ (sqrt(par.modIndex)-1);
else
	error('Unknown Modulation Type');
end

% Prepend the preamble and zero padding
symbols_all_tx = cat(1, repmat(preamble, [par.nPreamble, 1]), symbols_tx, zeros(TxDelay, 1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Transmitter Upsampling and Passband 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pulse shaping and upsample
%signal_bb_tx = rcosflt(symbols_all_tx,1,nOS,'filter',rrcfilter);
signal_bb_tx = upfirdn(symbols_all_tx, rrcfilter2, nOS, 1);
%signal_bb_tx = kron(symbols_all_tx, ones(nOS,1)); 

%t=0:length(signal_bb_tx)-1;
%signal_bb_tx = sin(2*pi*0.1e6./40e6*t.');
%signal_bb_tx = exp(1j*2*pi*0.5e6/40e6*t.');

% Mix up to intermediate frequency
time = [0:1:length(signal_bb_tx)-1]/40e6; % Sampling Freq. is 40MHz
signal_pb_tx = signal_bb_tx.* exp(sqrt(-1)*2*pi* par.fint * time).';

signal_pb_tx =  Hd.filter(signal_pb_tx);

% Scale signal to transmit so that it spans [-1,1] range. We do this to
% use the full range of the DAC at the tranmitter
scale = 1 / max( [ max(real(signal_pb_tx)) , max(imag(signal_pb_tx)) ] );
signal_pb_scale_tx = scale*signal_pb_tx/2; %Joe adjusts the baseband Tx gain 6/2/2015!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(par.opMode, 'Simulation')
	
	% Channel properties
	maxDopplerShift  = 200;      % Maximum Doppler shift of diffuse components (Hz)
	delayVector = (0:5:15)*1e-9; % Discrete delays of four-path channel (s)
	gainVector  = [0 -6 -9 -12];  % Average path gains (dB)
	KFactor = 10;					% Linear ratio of specular power to diffuse power
	specDopplerShift = 5;			% Doppler shift of specular component (Hz)
	snr = 20;
	
	% Create an Rician Fading channel model
	hRicChan = ricianchan(	1/(40e6), ...		% the sample time of the input signal, in seconds. 
							maxDopplerShift, ...% the maximum Doppler shift, in hertz
							KFactor, ... 
							delayVector, ...
							gainVector);
	hRicChan.StoreHistory = true;
						
	% Process multipath filtering
	signal_pb_rx = hRicChan.filter(signal_pb_scale_tx);
	%signal_pb_rx = signal_pb_scale_tx;
	
	% Add AWGN
	signal_pb_rx = awgn(signal_pb_rx, snr);
	
	% Introduce some delay
	signal_pb_rx = cat(1, zeros(TxDelay, 1),signal_pb_rx);
	signal_pb_rx = signal_pb_rx(1:length(signal_pb_scale_tx));
	
	% Add some CFO 
	t = 0:length(signal_pb_rx)-1;
	signal_pb_rx = signal_pb_rx .* exp(1j * 2 * pi * 1.5e5 / 40e6 * t.');
	
	signal_pb_rx = signal_pb_rx + 0.2*exp(1j * 2 * pi * 34e6 ./ 40e6 * t.') ...
						+ 0.1*exp(1j * 2 * pi * 46e6 ./ 40e6 * t.');
	
elseif strcmp(par.opMode, 'WARP')
	% Check if WARP already has been initiatialized
	%if(~exist('WARPReady', 'var')); WARP_Init; end
	WARP_Init;
	
	%% DEBUG
% 	t=0:length(signal_pb_tx)-1;
% 	signal_pb_tx = exp(1j * 2 * pi * par.fint/40e6 * t.'); % sin(2*pi*t.'*5e6/40e6);
% 	signal_pb_scale_tx = signal_pb_tx;

	
	% Write data in transmit buffers
	Node1_Radio4_TxData = signal_pb_scale_tx.';
	%download samples to ANALOG CARD, enable tx, enable tx buffer
	warplab_writeSMWO(udp_node1, RADIO4_TXDATA, Node1_Radio4_TxData);
	pause(0.1);

	% enable Tx on node 1
	warplab_sendCmd(udp_node1, RADIO4_TXEN, packetNum);
	warplab_sendCmd(udp_node1, RADIO4TXBUFF_TXEN, packetNum);

	% enable Rx on node 2
	warplab_sendCmd(udp_node2, RADIO4_RXEN, packetNum);
	warplab_sendCmd(udp_node2, RADIO4RXBUFF_RXEN, packetNum);

	% % Prime transmitter state machine in node 1. Node 1 will be 
	% % waiting for the SYNC packet. Transmission from node 1 will be triggered 
	% % when node 1 receives the SYNC packet.
	warplab_sendCmd(udp_node1, TX_START, packetNum);

	% % Prime receiver state machine in node 1. Node 1 will be waiting 
	% % for the SYNC packet. Capture at node 1 will be triggered when node 1 
	% % receives the SYNC packet.
	warplab_sendCmd(udp_node2, RX_START, packetNum);
	
	% Toggle signal transmission
	disp('Triggering WARPLab transmission ...');
	pause(0);
	warplab_sendSync(udp_Sync);
	pause(0.1);
	
	% Fetch data from buffers
	[Node2_Radio4_RawRxData] = warplab_readSMRO(udp_node2, RADIO4_RXDATA, TxLength+TxDelay+100);
	% Process the received samples to obtain meaningful data

	[Node2_Radio4_RxData,Node2_Radio4_RxOTR] = warplab_processRawRxData(Node2_Radio4_RawRxData);
	%  Node2_Radio4_RxData=-1.*Node2_Radio4_RxData;
	% pause(5);
	
	%pause(600);
	
	% Set radio 2 Tx buffer in node 1 back to Tx disabled mode
	warplab_sendCmd(udp_node1, RADIO4TXBUFF_TXDIS, packetNum);

	% Disable the transmitter radio
	warplab_sendCmd(udp_node1, RADIO4_TXDIS, packetNum);

	% Set radio 2 Rx buffer in node 1 back to Rx disabled mode
	warplab_sendCmd(udp_node2, RADIO4RXBUFF_RXDIS, packetNum);

	% Disable the receiver radio
	warplab_sendCmd(udp_node2, RADIO4_RXDIS, packetNum);

	signal_pb_rx = Node2_Radio4_RxData(1:length(Node1_Radio4_TxData)).';
	%signal_pb_rx = conj(signal_pb_rx);
	
else
	error('Unknown Operation Mode');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver Downsampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove the DC part
signal_pb_rx = signal_pb_rx - mean(signal_pb_rx);

%Filter
signal_pb_rx_filt_in = signal_pb_rx;
signal_pb_rx =  Hd_pb.filter(signal_pb_rx);

% Downconvert to baseband
time = [0:1:length(signal_bb_tx)-1]/40e6;
signal_bb_rx = signal_pb_rx .* exp(-sqrt(-1)*2*pi*par.fint*time.');


% Filter the baseband
signal_bb_rx = filter(B, A, signal_bb_rx);

preamble_upsamp  = upfirdn(repmat(preamble, par.nPreamble, 1), rrcfilter2, nOS, 1);
delay			= finddelay(sign(preamble_upsamp), sign(signal_bb_rx),120);
signal_bb_rx	= circshift(signal_bb_rx, delay * -1);

% Compute the CFO in baseband
cfo_tx			= preamble_upsamp;
cfo_rx			= signal_bb_rx(1:length(preamble_upsamp));
cfo_drift		= cfo_rx ./ cfo_tx;
cfo_drift		= cfo_drift(2:end) ./ cfo_drift(1:end-1);

cfo_drift_m		= exp(1j*angle(mean(cfo_drift)));

% Apply the CFO correction
t				= 1:length(signal_bb_rx); 
%signal_bb_rx	= signal_bb_rx .* exp(-1j * angle(cfo_drift_m) .* t.'); 

% Matched Filter
symbols_all_rx = upfirdn(signal_bb_rx,rrcfilter2,1,nOS);   % Downsample and filter
symbols_all_rx = symbols_all_rx(span+1:end-span);          % Account for delay

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Receiver Decoding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Estimate the CFO based on the preamble symbols
cfo_pre			= symbols_all_rx(1:length(preamble) * par.nPreamble);
cfo_ref			= repmat(preamble, par.nPreamble, 1);

cfo_shift		= cfo_pre .* conj(cfo_ref);
cfo_diffs		= unwrap(diff(angle(cfo_shift),1),2);

cfo_diff		= mean(cfo_diffs);
cfo_hz			= cfo_diff / 2 / pi * 40e6 / nOS;

% Apply the CFO correction
t				= 1:length(symbols_all_rx); 
% symbols_all_rx	= symbols_all_rx .* exp(-1j * cfo_diff .* t.');
% symbols_all_rx = symbols_all_rx .* exp(-1j * 2 * pi * 1.5e5 / 40e6 * nOS * t.');


% Cut the right signal parts
preamble_len	= length(preamble) * par.nPreamble;
preamble_rx		= symbols_all_rx(1:preamble_len);
symbols_rx		= symbols_all_rx(preamble_len+1:preamble_len+nSym);

% Estimate the channel
reference		= repmat(preamble, par.nPreamble, 1);
channel			= mean(preamble_rx ./ reference);
channel_var		= var(preamble_rx ./ reference);

% Apply the channel correction, streches the received signal to the
% expected modulation
symbols_rx		= symbols_rx ./ channel;

% Decode the data using either PSK or QAM
if strcmp(par.modType, 'PSK')
	payload_rx = dpskdemod(symbols_rx, par.modIndex);
elseif  strcmp(par.modType, 'QAM')
	%symbols_rx = symbols_rx .* (sqrt(par.modIndex)-1);
	payload_rx = qamdemod(symbols_rx .* (sqrt(par.modIndex)-1), par.modIndex);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Evaluation and Error Determination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine the RMS of the passband signal
res.rms = rms(signal_pb_rx);

% Determine the Bit-Error-Rate
[~, res.ber]	= biterr(payload_tx, payload_rx);

% Determine the Symbol-Error-Rate
[~, res.ser]	= symerr(payload_tx, payload_rx);

% Store the delay
res.delay		= delay;

% Store the CFO
res.cfo_hz		= cfo_hz;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualize the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Plot the transmitted and received passband signal
% hfig_bb_time = figure('Name', 'Passband Signal (Time Domain)','NumberTitle','off');
% hold on;
% tx = signal_pb_tx;
% rx = signal_pb_rx;
% t=0:length(tx)-1;
% subplot(2,1,1);
% plot(	t, real(tx), ...
% 		t, imag(tx) );
% xlabel('time samples');
% title('Transmitted Signal');
% legend('real','imag');
% subplot(2,1,2);
% plot(	t, real(rx), ...
% 		t, imag(rx) );
% xlabel('time samples');
% title('Received Signal');
% legend('real','imag');
% hold off;
% 
% freqspec(tx,rx,40e6);
% 
% % Plot the phase drift
% ph = exp(1j*angle(rx ./tx));
% freqspec(ph,ph,40e6)
% drift = ph(2:end) ./ ph(1:end-1);
% scatterplot(drift);
% 
% % Plot the transmitted and received baseband signal
% hfig_bb_time = figure('Name', 'Baseband Signal (Time Domain)','NumberTitle','off');
% hold on;
% tx = signal_bb_tx(1:400);
% rx = signal_bb_rx(1:400);
% t=0:length(tx)-1;
% subplot(3,1,1);
% plot(	t, real(tx), ...
% 		t, imag(tx), ...
% 		t, abs(tx));
% xlabel('time samples');
% title('Transmitted Signal');
% legend('real','imag');
% subplot(3,1,2);
% plot(	t, real(rx), ...
% 		t, imag(rx), ...
% 		t, abs(rx));
% xlabel('time samples');
% title('Received Signal');
% legend('real','imag');
% subplot(3,1,3);
% plot(	t, unwrap(angle(rx) - angle(tx)));
% xlabel('time samples');
% title('Phase Shift');
% 
% hold off;
% 
% freqspec(tx,rx,40e6);
% 
% Plot the phase drift
% ph = exp(1j*angle(rx ./tx));
% freqspec(ph,ph,40e6)
% drift = ph(2:end) ./ ph(1:end-1);
% scatterplot(drift);
% 
% % Plot the received constellation
% plot_constwithevm(symbols_tx, symbols_rx);
% 
% % Plot the preamble constellation
% plot_constwithevm(reference, preamble_rx);
% %scatterplot(preamble_rx);
% 
% % Plot the Passband Frequency Spectrum
% freqspec(signal_pb_tx(100:501), signal_pb_rx(100:501), 40e6);
% 
% freqspec(signal_bb_tx, signal_bb_rx, 40e6);
