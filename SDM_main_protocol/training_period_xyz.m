function [RX_measure_report, Beam_index_report,tr_oh] = training_period_xyz(client_spec,cb_id)
    %Loading Network Parameters
    load global_params_incr.mat
    N_u = size(client_spec,1);
    RX_measure_report = NaN(Nap_bw,N_u);
    Beam_index_report = -1*ones(Nap_bw,N_u);
    t_tr_o = 0;
    t_fb_o = 0;
    
    cb_tree = cb_trees{cb_id};

    filled = zeros(Ncodewords_bw(Nap_bw),Nap_bw);
    filled(1:Ncodewords_bw(1),1) = 1;
    
    unreachable = client_spec(:,1);
    LOS_cl = [];
    deferred = [];

    unreachable_deference = 0;
    NLOS_deference = 0;
    
    for q=1:1:Nap_bw
%         unreachable
%          unreachable_deference
%          NLOS_deference
        RX_measure = NaN(Ncodewords_bw(q),N_u);

        if(isempty(unreachable) ==0)
            filled(1:Ncodewords_bw(q),q) = 1;
        end
        
        if(isempty(deferred)==0 & q== Nap_bw)
            filled(1:Ncodewords_bw(q),q) = 1;
            deferred = [];
        end
        

        %TRAINING BEACON PERIOD
        for v=1:1:Ncodewords_bw(q)

            if(filled(v,q) == 1)
                t_tr_o = t_tr_o + T_tr_pkt;
                for user=1:1:N_u
                    if(q < Nap_bw && ismember(client_spec(user,1),deferred) == 0)
                        RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                    elseif(q == Nap_bw)
                        RX_measure(v,user) = standard_pow_cb(cb_id,q,v,client_spec(user,1),client_spec(user,2));
                    end
                end
            end
        end

        t_tr_o = t_tr_o + T_tr_level_offset;

        %FEEDBACK PERIOD
        N_non_deferred = N_u - max(size(deferred));
        t_fb_o = t_fb_o + (N_non_deferred*T_fb_pkt);

        for user=1:1:N_u
            [~,best_beam] = max(squeeze(RX_measure(1:Ncodewords_bw(q),user)));
            if(q < Nap_bw)                
                % Checking LOS to NLOS movement
                if(ismember(client_spec(user,1),LOS_cl))
                    %Finding Children
%                     LOS_cl
%                     deferred
%                     unreachable
%                     best_beam
%                     JJ = RX_measure(1:Ncodewords_bw(q),user)
%                     k = q-1
%                     u = client_spec(user,1)
%                     g = Beam_index_report(1:k,user)
%                     h = RX_measure_report(1:k,user)
                    parent_id = find(strcmp(cb_tree,['(' num2str(q-1) ',' num2str(Beam_index_report(q-1,user)) ')']));
                    children = cb_tree.getchildren(parent_id);
                    child_candi = [];

                    if(isempty(children)==0)
                        for c=1:1:max(size(children))
                            code = cb_tree.get(children(c));
                            start = strfind(code,',') + 1;
                            fin = strfind(code,')')-1;
                            ind = str2num(code(start:fin));
                            child_candi = [child_candi;ind];
                        end
                    end

                    if(sum(isnan(squeeze(RX_measure(:,user)))) == Ncodewords_bw(q))
                        'No beacon heard'
                    end
                    
                    %if(RX_measure(best_beam,user) < RX_measure_report(q-1,user) || ismember(best_beam,child_candi)==0)
                    if(RX_measure(best_beam,user) < P_RX_min || sum(isnan(squeeze(RX_measure(:,user)))) == Ncodewords_bw(q))
                        LOS_cl = LOS_cl(LOS_cl~=client_spec(user,1));
                        deferred = [deferred; client_spec(user,1)];
                        NLOS_deference = 1;
                    end
                end

                % Checking Unreachability to Reachability Movement
                if(RX_measure(best_beam,user) >= P_RX_min && ismember(client_spec(user,1),unreachable))
                    unreachable = unreachable(unreachable~=client_spec(user,1));
                    LOS_cl = [LOS_cl; client_spec(user,1)];
                end

                if(ismember(client_spec(user,1),LOS_cl))
                    %Finding Children
                    parent_id = find(strcmp(cb_tree,['(' num2str(q) ',' num2str(best_beam) ')']));
                    children2 = cb_tree.getchildren(parent_id);

                    if(q < Nap_bw && isempty(children2)==0)
                        for c=1:1:max(size(children2))
                            code = cb_tree.get(children2(c));
                            start = strfind(code,',') + 1;
                            fin = strfind(code,')')-1;
                            ind = str2num(code(start:fin));
                            filled(ind,q+1) = 1;
                        end
                    end
                end
            end
            if(RX_measure(best_beam,user) >= P_RX_min)
                 RX_measure_report(q,user) = RX_measure(best_beam,user);
                 Beam_index_report(q,user) = best_beam;
            end
        end

        if(NLOS_deference == 1 && isempty(unreachable)==0)
            unreachable_deference = 1;
            deferred = [deferred;unreachable];
            unreachable =[];
        end
        
    end
    
    tr_oh = t_tr_o + t_fb_o;
    %unreachable_deference
    %NLOS_deference
    
end
            




