function [transmit_angle,receive_angle]=angle_get(TX_location,RX_location)
%obtain the angel of transmit and receive
theta=atan((TX_location(2)-RX_location(2))/(TX_location(1)-RX_location(1)));
if theta<0
    if TX_location(1)<RX_location(1)
        transmit_angle=theta+2*pi;
        receive_angle=theta+pi;
    else
        transmit_angle=theta+pi;
        receive_angle=theta+2*pi;
    end
else
    if TX_location(1)<RX_location(1)
        transmit_angle=theta;
        receive_angle=theta+pi;
    else
        transmit_angle=theta+pi;
        receive_angle=theta;
    end
end