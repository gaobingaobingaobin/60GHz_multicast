function [d_s, Nbeams_lev] = beam_gen_SDM(RX_measure_report, Beam_index_report,RX_full_measure)
%BEAM GROUP GENERATION SELECTING WEAKEST CLIENT FIRST

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);
    
    %Initial Solution = Only Finest Beams
    d_s_finest = 0;
    
    Nbeams_lev = zeros(Nap_bw,1);
    
    for b=1:1:Ncodewords_bw(Nap_bw)
        clients = find(squeeze(Beam_index_report(Nap_bw,:)) == b);
        if(isempty(clients) == 0)
            loc_min = min(RX_measure_report(Nap_bw,clients));
            d_s_finest = d_s_finest + (L_min/DataRate(loc_min));
        end
    end    
    
    % NOW FINDING THE RESULTANT SWEEP TIMES WITH A SINGLE ADDITION OF A
    % WIDENED BEAM
    
    goodBeamMap = containers.Map('KeyType','char','ValueType','double');
    
    
    for q=1:1:Nap_bw-1
        for v=1:1:Ncodewords_bw(q)
             
            %Find out if any client has this pattern
            widen_clients = find(squeeze(RX_full_measure(q,v,:)) >= P_RX_min);   
            
            if(isempty(widen_clients) == 0)
                %Widened beam
                loc_min = min(RX_full_measure(q,v,widen_clients));
                D_curr = L_min/DataRate(loc_min);
                
                %Remaining clients served by Finest Beams
                for b=1:1:Ncodewords_bw(Nap_bw)
                    clu = find(squeeze(Beam_index_report(Nap_bw,:)) == b);
                    xsect = intersect(widen_clients,clu);
                    clu = setxor(clu,xsect);
                    if(isempty(clu) == 0)
                        loc_min = min(RX_measure_report(Nap_bw,clu));
                        D_curr = D_curr + (L_min/DataRate(loc_min));
                    end
                end
                
                if(D_curr < d_s_finest)
                    good_beam_ratio(v,q) = 1e6*d_s_finest/D_curr;
                     %gbr = d_s_finest/D_curr
                     %gbr_count = gbr_count + 1;
                     %code = [num2str(v) ',' num2str(q)];
                    goodBeamMap([num2str(v) ',' num2str(q)]) = 1e6*d_s_finest/D_curr;
                end
            end
        end
    end
        
    if(isempty(goodBeamMap))
        d_s = d_s_finest;
    else
        %Initial Traversal through the Hash Map

        % SORTING THE GOOD BEAMS BASED ON THE GOOD BEAM RATIO
        good_beam_ratios_sort = sort(cell2mat(values(goodBeamMap)),'descend');
        widened_clients = []; %Clients finally present in wide beams
        d_s_final = 0;
        better = max(size(good_beam_ratios_sort));
        valid = 0;
        %Initial Traversal through the Hash Map

        while(max(size(widened_clients)) < N_u)

            good_beam_ratios_sort = sort(cell2mat(values(goodBeamMap)),'descend');

            if(isempty(good_beam_ratios_sort))
                break;
            end

            gbr_val = good_beam_ratios_sort(1);

            keySet = keys(goodBeamMap);
            Nkeys = max(size(keySet));

            code = '';

            for n=1:1:Nkeys
                if(goodBeamMap(keySet{n}) == gbr_val)
                    code = keySet{n};
                    break;
                end
            end

    %         Deleting the main key from the hashmap
    %         remove(goodBeamMap,code);

            %Decoding the corresponding codeword

            comma = strfind(code,',');
            patt_id = str2num(code(1:comma-1));
            lev = str2num(code(comma+1:end));

            current_widen = find(squeeze(RX_full_measure(lev,patt_id,:)) >= P_RX_min);

            %Check if any of these clients are already inside the widened
            %client list; If yes, then ignore this beam and go to next

            new_clients = setxor(current_widen,intersect(widened_clients,current_widen));

            if(isempty(intersect(widened_clients,current_widen)))
                loc_min = min(squeeze(RX_full_measure(lev,patt_id,current_widen)));
                Nbeams_lev(lev) = Nbeams_lev(lev) + 1;
                
                d_s_final = d_s_final + (L_min/DataRate(loc_min));
                widened_clients = [widened_clients; current_widen];

                %Deleting all keys with this pattern or clients
                for n=1:1:Nkeys
                    code = keySet{n};
                    comma = strfind(code,',');
                    patt_ids = str2num(code(1:comma-1));
                    levs = str2num(code(comma+1:end));

                    clu = find(squeeze(RX_full_measure(levs,patt_ids,:)) >= P_RX_min);

                    if(isempty(intersect(widened_clients,clu))==0)
                        remove(goodBeamMap,code);
                    end
                end
            end 
        end

        if(max(size(widened_clients)) < N_u)
            for b=1:1:Ncodewords_bw(Nap_bw)
                clu = find(squeeze(Beam_index_report(Nap_bw,:)) == b);
                xsect = intersect(widened_clients,clu);
                clu = setxor(clu,xsect);
                if(isempty(clu) == 0)
                    loc_min = min(RX_measure_report(Nap_bw,clu));                  
                    Nbeams_lev(Nap_bw) = Nbeams_lev(Nap_bw) + 1;
                    
                    d_s_final = d_s_final + (L_min/DataRate(loc_min));
                end
            end        
        end
        
        d_s = d_s_final;
    end
end

