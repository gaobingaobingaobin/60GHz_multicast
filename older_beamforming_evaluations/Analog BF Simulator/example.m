clear
TX_location=[1,1;   %location of TX1
             2,2];  %location of TX2
RX_location=[5,1.1; %location of RX1
             2.5,6];%location of RX1

TX_rotation=[0,0];  %rotation of transmitters' antenna array
RX_rotation=[0,pi]; %rotation of receivers' antenna array
room_size=[10,10];  %size of the room (meter)
M=8; %number of antenna elements on each phased-array antenna
K=8; %number of beam patterns (maximum value of K is 2M)
Pt=0.001; %tansmitting power (W)

%Sector search besed on SNR
[SNR,SINR]=A_BF_SIM_1(TX_location,RX_location,TX_rotation,RX_rotation,room_size,M,K,Pt)

%Initiate sector search in sequence. When a link starts sector search, the
%previous links are assumed to have been transmitting. Thus the current
%link selects the beam pair that achieves the highest SINR. The sequence
%makes a different to the selection and the performance
[SNR,SINR]=A_BF_SIM_2(TX_location,RX_location,TX_rotation,RX_rotation,room_size,M,K,Pt)