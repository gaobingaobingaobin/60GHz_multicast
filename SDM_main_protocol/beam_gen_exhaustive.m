function [d_s] = beam_gen_exhaustive(RX_measure_report,Beam_index_report, RX_full_measure)
%BEAM GROUP GENERATION USING EXHAUSTIVE SEARCH

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);

    clients = 1:1:N_u;
    [~,ind] = sort(Beam_index_report(Nap_bw,clients));
    clients = clients(ind);
    Nclients = N_u;

    if(Nclients==0)
        return;
    end

    d_s = Inf;
    
    if(Nclients == 1)
        delay = 0;
        for level=Nap_bw:-1:1
            if(Beam_index_report(level,clients) ~= -1)
                delay = L_min/DataRate(RX_measure_report(level,clients));
                if(delay < d_s)
                    d_s = delay;
                end
            end
        end
    else             
        for p=0:1:Nclients-1 %No. of beams
            
            if(p == 0)
                
                delay = 0;
                valid = 0;
                
                for q=1:1:Nap_bw
                    for v=1:1:Ncodewords_bw(q)
                        min_pw = min(squeeze(RX_full_measure(q,v,clients)));
                        if(min_pw >= P_RX_min)
                            valid = 1;
                            delay = L_min/DataRate(min_pw);
                        end
                    end
                end
                
                if(valid == 1 & delay < d_s)
                    d_s = delay;
                end
            else
                
                part_vec = 1:1:Nclients-1;
                candi_beams = combnk(part_vec,p);
                valid = 0;

                for set = 1:1:size(candi_beams,1)
                    delay = 0;
                    valid = 0;

                    for b=1:1:p+1
                        valid = 0;
                        clients_beam = [];
                        if(b==1)
                            clients_beam = client(1:candi_beams(set,1));
                        elseif(b <= p)
                            clients_beam = clients(candi_beams(set,b-1) + 1:candi_beams(set,b));
                        else
                            clients_beam = clients(candi_beams(set,b-1) + 1:Nclients);
                        end
                        
                        min_b = NaN(Nap_bw,1);
                        count_b = 0;
                        
                        for q=1:1:Nap_bw
                            for v=1:1:Ncodewords_bw(q)
                                min_pw = min(squeeze(RX_full_measure(q,v,clients_beam)));
                                if(min_pw >= P_RX_min)
                                    valid = 1;
                                    count_b = count_b + 1;
                                    min_b(count_b)= L_min/DataRate(min_pw);
                                end
                        end
                        if(valid == 0)
                            break;
                        else
                            delay = delay + min(min_b);
                        end
                    end

                    if(valid == 1 & delay < d_s)
                        d_s = delay;
                    end
                end
            end
        end
    end
end
