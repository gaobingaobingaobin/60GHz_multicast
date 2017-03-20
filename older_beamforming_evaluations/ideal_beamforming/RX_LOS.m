function [rx_measure] = RX_LOS(AP_loc,AP_rot, b_AP, client_loc, client_rot, b_cl)

load global_params_incr.mat;

beam_gain = 4*pi*pi*eta*eta/(b_AP*b_cl);
tx_rx_phi = atan2(client_loc(2) - AP_loc(2), client_loc(1) - AP_loc(1));
tx_rot_dev = abs(tx_rx_phi - AP_rot);
rx_rot_dev = abs(pi + tx_rx_phi - client_rot);
deviation_loss = 10^(1.2*((tx_rot_dev/b_AP)^2))*10^(1.2*((rx_rot_dev/b_cl)^2));
G_beam = beam_gain/deviation_loss;
tx_rx_dist = sqrt((AP_loc(1)-client_loc(1))^2 + (AP_loc(2) - client_loc(2))^2);

%RX_measure(or,u) = P_TX + (10*log10(abs(G_beam)^2)) - PL_0 - (10*alpha_coeff*log10(user_loc(u,1)/d_min));
PL = 10^((PL_0 + (10*alpha_coeff*log10(tx_rx_dist/d_0)))/10);
rx_measure_abs = P_TX*(abs(G_beam))/PL;
rx_measure = RX_offset + (10*log10(rx_measure_abs));

end

