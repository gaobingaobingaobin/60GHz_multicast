%% SetTransmissionConstants.m


% Compute dependent parameters
nOS		= 40e6 ./ par.fsamp;

% Set the preamble
preamble = [1 1  1 1 1 -1 -1 1 1 -1 1 -1 1]';

% % Define parameters related to the pulse shaping filter and create the 
% % pulse shaping filter
% % This pulse shaping filter is a Squared Root Raised Cosine (SRRC) filter
% filtorder = nOS * 8; % Filter order
% delay = filtorder/(nOS*2); % Group delay (# of input samples). Group 
% % delay is the time between the input to the filter and the filter's peak 
% % response counted in number of input samples. In number of output samples
% % the delay would be equal to 'delay*nsam'.
% rolloff = 0.3; % Rolloff factor of filter
% rrcfilter = rcosine(1,nOS,'fir/sqrt',rolloff,delay); % Create SRRC filter

span		= 6;        % Filter span in symbols
rolloff		= 0.25;   % Roloff factor of filter
rrcfilter2	=  rcosdesign(rolloff, span, nOS);


d = fdesign.bandpass('N,F3dB1,F3dB2',10,par.fint-par.fsamp,par.fint+par.fsamp,40e6);
Hd = design(d,'butter');


d = fdesign.bandpass('N,F3dB1,F3dB2',10,par.fint-par.fsamp,par.fint+par.fsamp,40e6);
Hd_pb = design(d,'butter');

fc = par.fsamp;		% Cut-off frequency (Hz)
fs = 40e6;			% Sampling rate (Hz)
order = 10;			% Filter order
[B,A] = butter(order,2*fc/fs);