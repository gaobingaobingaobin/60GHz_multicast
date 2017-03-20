function [RX_measure_report, RX_log_measure_report, Beam_index_report,t_tr_o,t_fb_o] = training_period(user_loc,K)
% COMPLETE SIMULATION OF THE TRAINING PERIOD OF K-level
% RX_report: Complete Received Power Measurement
% t_tr_o: Vector of overhead of AP transmitting training beacons at each
% codebook level
% t_fb_o: Vector of overhead of users providing feedback; they provide
%highest RX_measure and the Codebook ID in the feedback

%Loading Network Parameters
load global_params_incr.mat
N_u = size(user_loc,1);
RX_measure_report = NaN(K,N_u);
Beam_index_report = NaN(K,N_u);
t_tr_o = zeros(K,1);
t_fb_o = zeros(K,1);

filled = zeros(N_or(K),K);

for k=0:1:K-1
    
    if(k>0)
        t_tr_o(k+1) = t_tr_o(k+1) + t_tr_o(k);
        t_fb_o(k+1) = t_fb_o(k+1) + t_fb_o(k);
    end
    
    RX_measure = NaN(N_or(k+1),N_u);
    
    if(k==0)
        filled(1:N_or(k+1),k+1) = 1;
    end
    
    %TRAINING BEACON PERIOD
    for or=1:1:N_or(k+1)
        
        if(filled(or,k+1) == 1)
            t_tr_o(k+1) = t_tr_o(k+1) + T_tr_pkt;
            for u=1:1:N_u
                G_beam = 0;
                for m=0:1:M-1
                    G_beam = G_beam + (W_sw_opt(m+1,k+1,or)*(exp(sqrt(-1)*m*pi*sin(user_loc(u,2)))));
                end
                
                %RX_measure(or,u) = P_TX + (10*log10(abs(G_beam)^2)) - PL_0 - (10*alpha_coeff*log10(user_loc(u,1)/d_min));
                PL = 10^((PL_0 + (10*alpha_coeff*log10(user_loc(u,1)/d_min)))/10);
                RX_measure(or,u) = P_T*(abs(G_beam)^2)/PL;
            end
        end
    end
    
    t_tr_o(k+1) = t_tr_o(k+1) + T_tr_level_offset;
    
    %FEEDBACK PERIOD
    for u=1:1:N_u
        [~,best_beam] = max(squeeze(RX_measure(:,u)));
        RX_measure_report(k+1,u) = RX_measure(best_beam,u);
        RX_log_measure_report(k+1,u) = 32.5 + 10*log10(RX_measure_report(k+1,u));
        Beam_index_report(k+1,u) = best_beam;
        filled((best_beam-1)*N_B + 1:best_beam*N_B,k+2) = 1;
    end
    t_fb_o(k+1) = t_fb_o(k+1) + (N_u*T_fb_pkt);
        
end


end



