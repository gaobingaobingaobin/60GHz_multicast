function [rx_measure] = RX_NLOS(AP_loc, AP_rot, b_AP, client_loc, client_rot, b_cl, room_size)

load global_params_incr.mat;

L = room_size(2);
B = room_size(1);
Nwalls = 4; %id in clockwise direction
rot_range = NaN(Nwalls,2); %[min,max];

%% Identify the direction range of each wall and the wall of reflection

%Wall 1
rot_range(1,1) = 2*pi - atan(AP_loc(2)/B-AP_loc(1));
rot_range(1,2) = atan((L-AP_loc(2))/(B - AP_loc(1)));

%Wall 2
rot_range(2,1) = rot_range(1,2) + realmin;
rot_range(2,2) = (pi/2) + atan(AP_loc(1)/(L- AP_loc(2)));

%Wall 3
rot_range(3,1) = rot_range(2,2) + realmin;
rot_range(3,2) = pi + atan(AP_loc(1)/(L- AP_loc(2)));

%Wall 4
rot_range(4,1) = rot_range(3,2) + realmin;
rot_range(4,2) = rot_range(1,1) - realmin;

wall_id = NaN;
for wall=1:1:Nwalls
    if(wall == 1)
        if(AP_rot >= rot_range(1,2) || AP_rot <= rot_range(1,1))
            wall_id = 1;
            break;
        end
    else
        if(AP_rot >= rot_range(wall,1) && AP_rot <= rot_range(wall,2))
            wall_id = wall;
            break;
        end
    end
end

%% Identify the reflection point, direction of reflection signal and TX-to-Reflection Point Path Loss
ref_loc = NaN(2,1);
ref_rot = NaN;

if(wall_id == 1)
    ref_loc(1) = B;
    ref_loc(2) = AP_loc(2) + ((B-AP_loc(1))*tan(AP_rot));
    ref_rot = pi - AP_rot;
elseif(wall_id == 2)
    ref_loc(1) = AP_loc(1) + ((L-AP_loc(2))*cot(AP_rot));
    ref_loc(2) = L;
    ref_rot = 2*pi - AP_rot;
elseif(wall_id == 3)
    ref_loc(1) = 0;
    ref_loc(2) = AP_loc(2) + (AP_loc(1)*tan(pi - AP_rot));
    ref_rot = pi - AP_rot;
elseif(wall_id == 4)
    ref_loc(1) = AP_loc(1) - (AP_loc(2)*cot(AP_rot - pi));
    ref_loc(2) = 0;
    ref_rot = (2*pi) - AP_rot;
end

if(ref_rot < 0) ref_rot = ref_rot + (2*pi); end    

tx_ref_dist =  sqrt((AP_loc(1)-ref_loc(1))^2 + (AP_loc(2) - ref_loc(2))^2);
tx_ref_PL = 10*alpha_coeff*log10(tx_ref_dist/d_0);
 
% Call RX_LOS to obtain RX_measure
rx_measure_ref_rx = RX_LOS(ref_loc,ref_rot, b_AP, client_loc, client_rot, b_cl);
rx_measure = tx_ref_PL + rx_measure_ref_rx;

end
