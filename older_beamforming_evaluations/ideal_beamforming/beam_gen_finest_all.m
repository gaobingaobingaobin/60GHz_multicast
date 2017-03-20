function [d_s,t_tr_o,t_fb_o] = beam_gen_finest_all(RX_measure_report,RX_log_measure_report, Beam_index_report)
%BEAM GROUP GENERATION USING FINEST BEAM TECHNIQUE

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);    
    d_s = 0;
    
    for b=1:1:m_t(N_T)
        clients = find(squeeze(Beam_index_report(N_T,:)) == b);
        if(isempty(clients) == 0)
            loc_min = min(RX_log_measure_report(N_T,clients));
            d_s = d_s + (L_max/DataRate(loc_min));
        end
    end
    
    t_tr_o = (m_t(N_T)*T_tr_pkt) + T_tr_level_offset;
    t_fb_o = N_u*T_fb_pkt;
    d_s = d_s/L_max;
end

