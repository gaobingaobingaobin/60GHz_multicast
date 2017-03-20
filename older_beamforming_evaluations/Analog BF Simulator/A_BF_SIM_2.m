function [SNR,SINR]=A_BF_SIM_2(TX_location,RX_location,TX_rotation,RX_rotation,room_size,M,K,Pt)

PN=7.9245e-11; %noise power (W)
N_a=length(TX_location(:,1)); %number of links
signal_power=zeros(1,N_a);
interference_power=zeros(1,N_a);
SINR=zeros(1,N_a);
SNR=zeros(1,N_a);
lamda=0.005; %wavelength of 60 GHz signal

%==================== generate beam patterns ====================
theta_vector=0:0.05:(2*pi);
A=zeros(K,length(theta_vector)); %beam patterns
W=zeros(M,K); %matirx of beamforming weight vectors
for m=0:M-1
    for k=0:K-1
        W(m+1,k+1)=1i^(floor(m*mod(k+K/2,K)/(K/4)));
    end
end
for k=1:K
    v=W(:,k);
    for i=0:(M-1)
        A(k,:)=A(k,:)+v(i+1)*exp(2*pi*1i*0.5*cos(theta_vector)*i);
    end
end
A=abs(A);
%{
polar(theta_vector,A(2,:),'b');
set(gca,'FontSize',25);
set(gcf,'color','white');
%}

%==================== select beam directions ====================
TX_beam_vector=zeros(M,N_a); %transmiters' beam weight vectors
RX_beam_vector=zeros(M,N_a); %receivers' beam weight vectors

% TX_beam_direction_best=zeros(1,N_a); %optimal angle of transmit
% RX_beam_direction_best=zeros(1,N_a); %optimal angle of receive
% for link=1:N_a
%     [transmit_angle,receive_angle]=angle_get(TX_location(link,:),RX_location(link,:));
%     TX_beam_direction_best(link)=transmit_angle;
%     RX_beam_direction_best(link)=receive_angle;
% end


for link=1:N_a
    SINR_matrix=zeros(K);
    SNR_matrix=zeros(K);
    for TX_beam_direction=1:K %exaustive search all beam pairs
        for RX_beam_direction=1:K
            TX_beam_vector(:,link)=W(:,TX_beam_direction);
            RX_beam_vector(:,link)=W(:,RX_beam_direction);
            %assume that link 1~'link'-1 have already started transmitting
            [current_SNR,current_SINR]=get_SINR(Pt,PN,M,link,lamda,TX_location,RX_location,TX_rotation,RX_rotation,room_size,RX_beam_vector,TX_beam_vector);
            SINR_matrix(TX_beam_direction,RX_beam_direction)=current_SINR;
            SNR_matrix(TX_beam_direction,RX_beam_direction)=current_SNR;
        end
    end
    %obtain the beam pair that achieves the highest SINR
    max_SINR=max(max(SINR_matrix));
    max_SNR=max(max(SNR_matrix));
    [TX_beam_direction_opt,RX_beam_direction_opt]=find(SINR_matrix==max_SINR);
    TX_beam_direction_opt=TX_beam_direction_opt(1);
    RX_beam_direction_opt=RX_beam_direction_opt(1);
    
    TX_beam_vector(:,link)=W(:,TX_beam_direction_opt);
    RX_beam_vector(:,link)=W(:,RX_beam_direction_opt);
    SNR(link)=max_SNR;
end


for TX=1:N_a
    for RX=1:N_a
        % obtain channel matrix H
        H=get_H(M,lamda,TX_location(TX,:),RX_location(RX,:),TX_rotation(TX),RX_rotation(RX),room_size);
        
        power=RX_beam_vector(:,RX)'*H*TX_beam_vector(:,TX);
        if TX==RX
            signal_power(RX)=Pt*abs(power)^2;
        else
            interference_power(RX)=interference_power(RX)+Pt*abs(power)^2;
        end
    end
end

for RX=1:N_a
    SINR(RX)=10*log10(signal_power(RX)/(interference_power(RX)+PN));
end






