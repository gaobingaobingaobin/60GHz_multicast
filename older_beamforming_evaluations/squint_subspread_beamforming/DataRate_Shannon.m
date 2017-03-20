function [shannon_rate] = DataRate_Shannon(P_RX)
%This function computes the Shannon limit's achievable data rate 
load global_params_incr;

SINR_measure = P_RX/PN;
shannon_rate = BW*log2(1 + SINR_measure);

end

