function H=get_H(M,lamda,TX_location,RX_location,TX_rotation,RX_rotation,room_size)
H=zeros(M); %channel matrix H
%direct path between TX and RX
d0=norm(TX_location-RX_location); % distance
[transmit_angle,receive_angle]=angle_get(TX_location,RX_location);
phi_0=receive_angle;
theta_0=transmit_angle;
g0=exp(1).^conj((1i*pi*cos(phi_0)*(0:M-1))')/sqrt(M);
p0=exp(1).^conj((1i*pi*cos(theta_0)*(0:M-1))')/sqrt(M);
c0=lamda/(4*pi*d0)*sqrt(0.1);% free space propagation loss
H=H+M*g0*c0*conj(p0)';

%four reflected paths
reflection_location=reflection_point(TX_location,RX_location,room_size); %get the locations of reflection points
for l=1:length(reflection_location(:,1))
    dl=norm(TX_location-reflection_location(l,:))+norm(RX_location-reflection_location(l,:));
    [transmit_angle,~]=angle_get(TX_location,reflection_location(l,:));
    theta_l=transmit_angle;
    [~,receive_angel]=angle_get(reflection_location(l,:),RX_location);
    phi_l=receive_angel;
    gl=exp(1).^conj((1i*pi*cos(phi_l)*(0:M-1))')/sqrt(M);
    pl=exp(1).^conj((1i*pi*cos(theta_l)*(0:M-1))')/sqrt(M);
    cl=lamda/(4*pi*dl)*sqrt(0.1)*sqrt(1/(10^0.6));% free space propagation loss & 6dB reflection loss
    
    % If the path is transmitted from/ arrives at the back side of the
    % antenna, it will be blocked by the device itself. 
    flag=0;
    theta_l=2*pi-theta_l;
    phi_l=2*pi-phi_l;
    if TX_rotation<pi
        if theta_l<TX_rotation
            flag=1;
        elseif TX_rotation+pi<theta_l
            flag=1;
        end
    else
        if TX_rotation-pi<theta_l && theta_l<TX_rotation
            flag=1;
        end
    end
    
    if RX_rotation<pi
        if phi_l<RX_rotation
            flag=1;
        elseif RX_rotation+pi<phi_l
            flag=1;
        end
    else
        if RX_rotation-pi<phi_l && phi_l<RX_rotation
            flag=1;
        end
    end
    
    H=H+M*gl*cl*pl'*flag;
end