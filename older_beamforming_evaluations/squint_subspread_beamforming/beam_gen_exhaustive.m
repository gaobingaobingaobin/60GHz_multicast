function [d_s] = beam_gen_exhaustive(RX_measure_report,RX_log_measure_report, Beam_index_report, k)
%BEAM GROUP GENERATION USING EXHAUSTIVE SEARCH

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);
    served = zeros(N_u,1);

    d_s = 0; %Total Multicast Transmission Delay per one sweep of client
    
    beam_count = 0;
    Beam_specs = zeros(N_u,2); %1st dimension is the codebook level, 2nd dimension is the beam index in the codebook level
    user_grouping = zeros(N_u,2);

    p_wb_opt = zeros(N_or(1),2); % Number of partitions and set number of the combination
    d_wb_opt = Inf(N_or(1),1); %optimal Delay per wide beam

    %STRATEGY: TO GO ONE WIDE SECTOR AFTER OTHER
    for wb = 1:1:N_or(1)
        %Identifying clients in this wide beam
        clients = find(squeeze(Beam_index_report(1,:)) == wb);
        [tmp,ind] = sort(Beam_index_report(k+1,clients));
        clients_sort = clients(ind);
        Nclients = length(clients);
        
        if(Nclients==0)
            continue;
        end
        
        d_min = Inf;
        p_min = 0;
        s_min = 0;
        
        if(Nclients == 1)
            delay = 0;
            for level=k:-1:0
                delay = (L_max/DataRate_Shannon(RX_log_measure_report(level+1,clients)));
                if(delay < d_min)
                    d_min = delay;
                end
            end
        else            
            for p=1:1:Nclients-1 %partitions - max = Nclients - 1
                part_vec = 1:1:Nclients-1;
                candi_beams = combnk(part_vec,p);

                for set = 1:1:size(candi_beams,1)
                    delay = 0;
                    invalid = 0;

                    for b=1:1:p
                        clients_beam = [];
                        if(b==1)
                            clients_beam = clients_sort(1:candi_beams(set,1));
                        else
                            clients_beam = clients_sort(candi_beams(set,b-1) + 1:candi_beams(set,b));
                        end


                        for level=k:-1:0
                            code = unique(Beam_index_report(level+1,clients_beam));
                            if(max(size(code)) == 1)
                                if(sum(Beam_index_report(level+1,:) == code) > max(size(clients_beam)))
                                    invalid = 1;
                                else
                                    delay = delay + (L_max/DataRate_Shannon(min(RX_log_measure_report(level+1,clients_beam))));
                                end
                                break;
                            end
                        end
                        if(invalid == 1)
                            break;
                        end
                    end

                    if(invalid == 0 & delay < d_min)
                        d_min = delay;
                        p_min = p;
                        s_min = set;
                    end
                end
            end

        end
        p_wb_opt(wb,1) = p_min;
        p_wb_opt(wb,2) = s_min;
        d_wb_opt(wb) = d_min;

    end

    d_s = sum(d_wb_opt);
    d_s = d_s/L_max;
    
end
