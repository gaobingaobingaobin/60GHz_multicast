function [d_s] = beam_gen_exhaustive(RX_measure_report,RX_log_measure_report, Beam_index_report)
%BEAM GROUP GENERATION USING EXHAUSTIVE SEARCH

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);
    served = zeros(N_u,1);

    d_s = 0; %Total Multicast Transmission Delay per one sweep of client
    
    beam_count = 0;
    Beam_specs = zeros(N_u,2); %1st dimension is the codebook level, 2nd dimension is the beam index in the codebook level
    user_grouping = zeros(N_u,2);

    p_wb_opt = zeros(N_br,2); % Number of partitions and set number of the combination
    d_wb_opt = zeros(N_br,1); %optimal Delay per wide beam

    %STRATEGY: TO GO ONE WIDE SECTOR AFTER OTHER
    N_fine_beams_per_wide_beam = m_t(N_T)/N_br_0;
    
    
    for wb = 1:1:N_br_0
        %Identifying clients in this wide beam
        clients = find(squeeze(Beam_index_report(N_T,:)) >= ((wb -1)*N_fine_beams_per_wide_beam) + 1);
        clients = intersect(clients, find(squeeze(Beam_index_report(N_T,:)) <= (wb*N_fine_beams_per_wide_beam)));
        [~,ind] = sort(Beam_index_report(N_T,clients));
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
            for level=N_T:-1:1
                if(Beam_index_report(level,clients) == -1)
                    break;
                end
                delay = (L_max/DataRate(RX_measure_report(level,clients)));
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


                        for level=N_T:-1:1
                            code = unique(Beam_index_report(level,clients_beam));
                            if(max(size(code)) == 1)
                                if(sum(Beam_index_report(level,:) == code) > max(size(clients_beam)) || code == -1)
                                    invalid = 1;
                                else
                                    delay = delay + (L_max/DataRate(min(RX_log_measure_report(level,clients_beam))));
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
