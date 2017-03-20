function [RX_measure_report, Beam_index_report,tr_oh] = training_period_basic_cb_dot(client_spec,cb_id)
    %Loading Network Parameters
    load global_params_incr.mat
    N_u = size(client_spec,1);
    RX_measure_report = NaN(Nap_bw,N_u);
    Beam_index_report = -1*ones(Nap_bw,N_u);
    t_tr_o = 0;
    t_fb_o = 0;

    cb_tree = cb_trees{cb_id};
    
    filled = zeros(Ncodewords_bw(Nap_bw),Nap_bw);
    filled(1:Ncodewords_bw(Nap_bw),Nap_bw) = 1;

    for q=Nap_bw:-1:1
        RX_measure = NaN(Ncodewords_bw(q),N_u);
        
        if(sum(squeeze(filled(:,q))) == 0) 
            break;
        end
        
        %TRAINING BEACON PERIOD
        for v=1:1:Ncodewords_bw(q)

            if(filled(v,q) == 1)
                t_tr_o = t_tr_o + T_tr_pkt;
                for user=1:1:N_u
                      RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                end
            end
        end

        t_tr_o = t_tr_o + T_tr_level_offset;

        %FEEDBACK PERIOD
        t_fb_o = t_fb_o + (N_u*T_fb_pkt);
        
        %FEEDBACK PERIOD
        for user=1:1:N_u
            [~,best_beam] = max(squeeze(RX_measure(1:Ncodewords_bw(q),user)));
            if(RX_measure(best_beam,user) >= P_RX_min)
                RX_measure_report(q,user) = RX_measure(best_beam,user);
                Beam_index_report(q,user) = best_beam;

                if(q > 1)
                    %Finding Parent
                    current_id = find(strcmp(cb_tree,['(' num2str(q) ',' num2str(best_beam) ')']));
                    parent_id = cb_tree.getparent(current_id);
                    code = cb_tree.get(parent_id);
                    start = strfind(code,',') + 1;
                    fin = strfind(code,')')-1;
                    ind = str2num(code(start:fin));
                    filled(ind,q-1) = 1;
                end
            end
%                 if(q < Nap_bw)
%                     filled(1:Ncodewords_bw(q-1),q-1) = 1;
%                 end
        end
    end
    tr_oh = t_tr_o + t_fb_o;  
    
end
            




