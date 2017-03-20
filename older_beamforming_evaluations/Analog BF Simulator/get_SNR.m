function [SNR]=get_SNR(Pt,PN,M,lamda,TX_location,RX_location,TX_rotation,RX_rotation,room_size,RX_beam_vector,TX_beam_vector)

% obtain channel matrix H
H=get_H(M,lamda,TX_location,RX_location,TX_rotation,RX_rotation,room_size);
power=RX_beam_vector'*H*TX_beam_vector;
signal_power=Pt*abs(power)^2;
SNR=10*log10(signal_power/PN);

