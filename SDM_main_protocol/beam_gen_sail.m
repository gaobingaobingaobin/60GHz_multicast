function [ d_s] = beam_gen_sail(RX_measure_report, Beam_index_report)
%BEAM GROUP GENERATION SELECTING WEAKEST CLIENT FIRST

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);
    served = zeros(N_u,1);
    
    d_s = 0; %Total Multicast Transmission Delay per one sweep of client
    
    
    beam_count = 0;
    Beam_specs = zeros(N_u,2); %1st dimension is the codebook level, 2nd dimension is the beam index in the codebook level
    user_grouping = zeros(N_u,2);

    %WHILE LOOP THAT TERMINATES ONCE ALL CLIENTS ARE SERVED
    while(sum(served) < N_u)
        
       beam_count = beam_count + 1;
       
        %Finding the main client (i.e. the client with weakest signal strength
        %at lowest codebook level = k
        served_locs = find(served == 1);
        unserved_locs = find(served == 0);
        n_unserved = max(size(unserved_locs));
        main_client = unserved_locs(randsample(n_unserved,1));

        %candi_set
        % We have obtained the Main Client and the Candidate Set
        % We are all set to perform the local optimization now
        %For each iteration, we will generate a beam from a different codebook level above and the
        %clients in the candidate list not served by this beam will be served
        %by beam at lowest codebook level
        D_min = Inf;
        
        candi_set =  unserved_locs;
        candi_set = setxor(unserved_locs,main_client);

        for l=Nap_bw:-1:1

            if(Beam_index_report(l,main_client) == -1)
                continue;
            end
            
            %Main Beam
            main_beam_candi = candi_set(squeeze(Beam_index_report(l,candi_set)) == Beam_index_report(l,main_client));
            %l
            %min(RX_log_measure_report(l+1,[main_beam_candi; main_client]))
            %rate = 1e-6*DataRate(min(RX_log_measure_report(l+1,[main_beam_candi; main_client])))
            if(isempty(main_beam_candi) == 0)
                loc_min = min(RX_measure_report(l,[main_beam_candi; main_client]));
            else
                loc_min = RX_measure_report(l,main_client);
            end
%             sz = max(size([main_beam_candi; main_client]))
%             l
%             r_curr = DataRate(loc_min)
            D_curr = L_min/DataRate(loc_min);

            if(isempty(candi_set) == 0)
                %Other Beams
                rem_candi = setxor(main_beam_candi,candi_set);
                best_beams_rem = unique(Beam_index_report(Nap_bw,rem_candi));

                if(isempty(rem_candi) == 0)
                    for i=1:1:size(rem_candi,1)
                        kk = squeeze(Beam_index_report(:,rem_candi(i)));
                        lev = max(find(kk ~= -1));
                        pow = RX_measure_report(lev,rem_candi(i));
                        D_curr = D_curr + (L_min/DataRate(pow));
                    end
                end
            end
            
            if(D_curr < D_min)                    
                D_min = D_curr;
                Beam_specs(beam_count,1) = l;
                Beam_specs(beam_count,2) = Beam_index_report(l,main_client);
            end
        end
        
%         r_cand
%         d_rate 
        %MOVING CLIENTS FROM SERVED TO UNSERVED
        if(isempty(candi_set)==0)
            final_beam_set = candi_set(squeeze(Beam_index_report(Beam_specs(beam_count,1),candi_set)) == Beam_specs(beam_count,2));
        else
            final_beam_set = [];
        end
        served([final_beam_set;main_client]) = 1;
        %h = Beam_specs(beam_count,1)
        %user_grouping([final_beam_set;main_client],1) = Beam_specs(beam_count,1);
        %user_grouping([final_beam_set;main_client],2) = Beam_specs(beam_count,1);
        
        %DELAY PER SWEEP UPDATE
        d_s = d_s + D_min;
        
    end
    
    d_s = d_s;

end

