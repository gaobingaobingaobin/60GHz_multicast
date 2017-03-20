%% Parameters.m
% Sets up the default parameters for the evalation bench. These might be
% updated by different evalation runs.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modulation Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modulatation Type
% Sets the modulation type used in the signal. Can be set to
% - 'PSK' for phase shift keying,
% - 'QAM' for quadrature amplitude
par.modType		= 'QAM';

% Modulation Index
% The modulation index gives the number of constellation points 
% in the modulation. Can be [2, 4, 8, 16] for PSK and [4, 8, 16, 64] for
% QAM
par.modIndex	= 4;

% Operation Mode
% Select whether signal is transmitted through a simulated channel 
% 'Simulation' or pushed to the WARP, 'WARP'
par.opMode = 'WARP';

% Sampling rate
% Sampling rate of symbols, must be [40, 20, 10, 5, 2.5, 1.25] * 1e6
par.fsamp = 5e6;

% Intermediate Frequency
% The frequency at which the signal is modulated in baseband
par.fint = 15e6;

% Number of preamble sequences
par.nPreamble = 3;


