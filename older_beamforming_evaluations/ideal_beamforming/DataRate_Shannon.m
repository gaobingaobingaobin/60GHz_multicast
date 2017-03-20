function [shannon_rate] = DataRate_Shannon(P_RX)
%This function computes the Shannon limit's achievable data rate 
load global_params_incr;

% if(P_RX < P_RX_min)
%     shannon_rate = -10;
%     rate_lower = -10;
%     'Unreachable Node - RX Power lower than Control Reqd.'
%     return;
% end

P_RX = 10^(P_RX/10);


SINR_measure = P_RX/PN;
shannon_rate = BW*log2(1 + SINR_measure);

end

