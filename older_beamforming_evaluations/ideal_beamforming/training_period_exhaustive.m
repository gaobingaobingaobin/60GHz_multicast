function [tr_oh] = training_period_exh(client_spec,cb_id)
    %Loading Network Parameters
    load global_params_incr.mat
    N_u = size(client_spec,1);
    
    t_tr_o = 0;
    t_fb_o = 0;
    
    for q=1:1:Nap_bw
        t_tr_o = t_tr_o + (Ncodewords_bw(q)*T_tr_pkt) + T_tr_level_offset;
        t_fb_o = t_fb_o + (N_u*T_fb_pkt);
    end
    
    tr_oh = t_tr_o + t_fb_o;
end




