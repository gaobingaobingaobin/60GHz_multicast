function [RX_measure_report, Beam_index_report,tr_oh] = training_period_only_finest(client_spec,cb_id)
    %Loading Network Parameters
    load global_params_incr.mat
    N_u = size(client_spec,1);
    RX_measure_report = NaN(Nap_bw,N_u);
    Beam_index_report = -1*ones(Nap_bw,N_u);
    t_tr_o = 0;
    t_fb_o = 0;


    for q=Nap_bw
        RX_measure = NaN(Ncodewords_bw(q),N_u);

        %TRAINING BEACON PERIOD
        for v=1:1:Ncodewords_bw(q)
            t_tr_o = t_tr_o + T_tr_pkt;
            for user=1:1:N_u
                if(q < Nap_bw && ismember(client_spec(user,1),deferred) == 0)
                    RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                else
                    RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                end
            end
        end

        t_tr_o = t_tr_o + T_tr_level_offset;
        t_fb_o = t_fb_o + N_u*(T_fb_pkt);

        %FEEDBACK PERIOD

        %FEEDBACK PERIOD
        for user=1:1:N_u
            [~,best_beam] = max(squeeze(RX_measure(1:Ncodewords_bw(q),user)));
            if(RX_measure(best_beam,user) >= P_RX_min)
                RX_measure_report(q,user) = RX_measure(best_beam,user);
                Beam_index_report(q,user) = best_beam;
            end
        end
    end
    tr_oh = t_tr_o + t_fb_o;    
end
            




