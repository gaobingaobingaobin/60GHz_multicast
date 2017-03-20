function [RX_measure_report, Beam_index_report,tr_oh,RX_full_measure] = training_period_SDM(client_spec,cb_id)
    %Loading Network Parameters
    load global_params_incr.mat
    N_u = size(client_spec,1);
    RX_measure_report = -Inf(Nap_bw,N_u);
    Beam_index_report = -1*ones(Nap_bw,N_u);
    t_tr_o = 0;
    t_fb_o = 0;
    
    cb_tree = cb_trees{cb_id};

    filled = zeros(Ncodewords_bw(Nap_bw),Nap_bw);
    filled(1:Ncodewords_bw(Nap_bw),Nap_bw) = 1;
    
    reachable = zeros(Nap_bw,N_u);

    RX_full_measure = -Inf(Nap_bw,Ncodewords_bw(Nap_bw),N_u);    
    
    for q=Nap_bw:-1:1
        RX_measure = -Inf(Ncodewords_bw(q),N_u);

        % INITIAL TRAINING BEACON PERIOD
        for v=1:1:Ncodewords_bw(q)
            if(filled(v,q) == 1)
                t_tr_o = t_tr_o + T_tr_pkt;
                for user=1:1:N_u
                    RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                end
            end
        end
        
        t_tr_o = t_tr_o + T_tr_level_offset;

        %INITIAL FEEDBACK PERIOD
        t_fb_o = t_fb_o + (N_u*T_fb_pkt);
        
        initial_unreach = [];
        
         for user=1:1:N_u
            [~,best_beam] = max(squeeze(RX_measure(1:Ncodewords_bw(q),user)));
            if(RX_measure(best_beam,user) >= P_RX_min)
                reachable(q,user) = 1;
                
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
            else
                initial_unreach = [initial_unreach;user];
            end
         end
        
         if(isempty(initial_unreach)==0 && q > 1 && q < Nap_bw)    
             
             add_tr = zeros(Ncodewords_bw(q),1);
             
             %Selecting the secondary patterns
             for u=1:1:max(size(initial_unreach))
                 user = initial_unreach(u);
                 if(reachable(q+1,user) == 1)
                       beam_finer = Beam_index_report(q+1,user);
                       
                       %Finding Ideal Beam that should have provided Beacon
                        current_id = find(strcmp(cb_tree,['(' num2str(q+1) ',' num2str(beam_finer) ')']));
                        parent_id = cb_tree.getparent(current_id);
                        code = cb_tree.get(parent_id);
                        start = strfind(code,',') + 1;
                        fin = strfind(code,')')-1;
                        beam_ind = str2num(code(start:fin)); 
                        
                        %Finding Parent of Ideal Beam
                        current_id = find(strcmp(cb_tree,['(' num2str(q) ',' num2str(beam_ind) ')']));
                        parent_id = cb_tree.getparent(current_id);
                        code = cb_tree.get(parent_id);
                        start = strfind(code,',') + 1;
                        fin = strfind(code,')')-1;
                        beam_ind_par = str2num(code(start:fin)); 
                        
                        %Finding Parent of Ideal Beam
                        parent_id = find(strcmp(cb_tree,['(' num2str(q-1) ',' num2str(beam_ind_par) ')']));
                        children = cb_tree.getchildren(parent_id);
                                                
                        for c=1:1:max(size(children))
                            code = cb_tree.get(children(c));
                            start = strfind(code,',') + 1;
                            fin = strfind(code,')')-1;
                            ind = str2num(code(start:fin));
                            
                            if(filled(ind,q) == 0)
                                add_tr(ind) = 1;
                            end
                        end
                 end
             end
             
             %SECOND TRAINING
             for v=1:1:Ncodewords_bw(q)
                if(add_tr(v) == 1)
                    t_tr_o = t_tr_o + T_tr_pkt;
                    for user=1:1:N_u
                        if(ismember(user,initial_unreach))
                            RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                        end
                    end
                end
             end
             
             %SECOND FEEDBACK
             t_fb_o = t_fb_o + (max(size(initial_unreach))*T_fb_pkt);
             
             for user=1:1:N_u
                if(ismember(user,initial_unreach))
                    [~,best_beam] = max(squeeze(RX_measure(1:Ncodewords_bw(q),user)));
                    if(RX_measure(best_beam,user) >= P_RX_min)
                        reachable(q,user) = 1;

                        RX_measure_report(q,user) = RX_measure(best_beam,user);
                        Beam_index_report(q,user) = best_beam;

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
             end
         end
         
         RX_full_measure(q,1:Ncodewords_bw(q),:) = RX_measure;
    end
    
    tr_oh = t_tr_o + t_fb_o;
    
end
            




