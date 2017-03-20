function [SNR,SINR]=get_SINR(Pt,PN,M,link,lamda,TX_location,RX_location,TX_rotation,RX_rotation,room_size,RX_beam_vector,TX_beam_vector)
%obtain the SINR of the No. 'link' link
RX=link;
signal_power=0;
interference_power=0;
for TX=1:link
    % obtain channel matrix H
    H=get_H(M,lamda,TX_location(TX,:),RX_location(RX,:),TX_rotation(TX),RX_rotation(RX),room_size);
    
    power=RX_beam_vector(:,RX)'*H*TX_beam_vector(:,TX);
    if TX==RX
        signal_power=Pt*abs(power)^2;
    else
        interference_power=interference_power+Pt*abs(power)^2;
    end
end


SINR=10*log10(signal_power/(interference_power+PN));
SNR=10*log10(signal_power/PN);

