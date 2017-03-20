function [d_s,t_tr_o,t_fb_o] = beam_gen_minimum_training(RX_measure_report,RX_log_measure_report, Beam_index_report)
%BEAM GROUP GENERATION USING FINEST BEAM TECHNIQUE

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2); 
    served = [];
    unserved = 1:1:N_u;
    d_s = 0;
    
    t_tr_o = 0;
    t_fb_o = 0;
    
    %Training Overhead needs to be re-calculated for the following reasons:
    % a) Training Feedback for each user happens only once - although we
    % might go one level down for training yet to be unidentified users,
    % the already identified users do not provide feedback
    
    %Initial Widest Beam stage
    q = 0;
    
    while(isempty(unserved)==0 && q < N_T)
        %Some clients cannot be reached by the widest beam
        q = q + 1;
        t_fb_o = t_fb_o + (max(size(unserved))*T_fb_pkt);
        for b=1:1:m_t(q)
            clients = unserved(find(squeeze(Beam_index_report(q,unserved)) == b));
            if(isempty(clients)==0)
                loc_min = min(RX_log_measure_report(q,clients));
                d_s = d_s + (L_max/DataRate(loc_min));
                unserved = setxor(unserved,clients);
                served = [served clients];
            end
        end

        t_tr_o = t_tr_o + (m_t(q)*T_tr_pkt);
        t_tr_o = t_tr_o + T_tr_level_offset;
    end

    d_s = d_s/L_max;
    t_total_o = t_tr_o + t_fb_o;
end

