function [d_s,better] = beam_gen_swirl_rapid(RX_measure_report, Beam_index_report,RX_full_measure)
%BEAM GROUP GENERATION SELECTING WEAKEST CLIENT FIRST

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);
    
    %Initial Solution = Only Finest Beams
    d_s_finest = 0;
    
    
    for b=1:1:Ncodewords_bw(Nap_bw)
        clients = find(squeeze(Beam_index_report(Nap_bw,:)) == b);
        if(isempty(clients) == 0)
            loc_min = min(RX_measure_report(Nap_bw,clients));
            d_s_finest = d_s_finest + (L_min/DataRate(loc_min));
        end
    end    
    
    % NOW FINDING THE RESULTANT SWEEP TIMES WITH A SINGLE ADDITION OF A
    % WIDENED BEAM
    
    %good_beam_ratio = zeros(Ncodewords_bw(Nap_bw),Nap_bw);       
    goodBeamMap = containers.Map('KeyType','char','ValueType','double');
    
    %gbr_count = 0;
    
    for q=1:1:Nap_bw-1
        for v=1:1:Ncodewords_bw(q)
             
            %Find out if any client has this pattern
            widen_clients = find(squeeze(RX_full_measure(q,v,:)) >= P_RX_min);   
            
            if(isempty(widen_clients) == 0)
                
                
                %Going through every possible subset of widen_clients
                Nwiden = max(size(widen_clients));
                
                if(Nwiden == 1)
                    continue;
                end
                
                for n=2:1:Nwiden
                    subs = combnk(widen_clients,n);
                    
                    for j=1:1:size(subs,1)
                        widen_sub = subs(j,:);
                        
                        %Widened beam
                        loc_min = min(RX_full_measure(q,v,widen_sub));
                        D_curr = L_min/DataRate(loc_min);
                        
                        %In Finest beams
                        D_fine = 0;
                        sub_code = '|';
                        for u=1:1:n
                            sub_code = [sub_code num2str(widen_sub(u)) ';'];
                            clu = find(squeeze(Beam_index_report(Nap_bw,:)) == Beam_index_report(Nap_bw,widen_sub(u)));
                            if(isempty(clu) == 0)
                               loc_min = min(RX_measure_report(Nap_bw,clu));
                               D_fine = D_fine + (L_min/DataRate(loc_min));
                            end
                        end
                        
                        sub_code = [sub_code(1:end-1)];
                        
                        if(D_curr < D_fine)
                            code = [num2str(v) ',' num2str(q) sub_code];
                            goodBeamMap(code) = 1e6*D_fine/D_curr;
                        end
                    end   
                end
            end
        end
    end
    
    goodBeamMap_init = goodBeamMap;
    
    %keys(goodBeamMap)
    
    
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
        
        valid =1;
        
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
                
%         %Deleting the main key from the hashmap
%         remove(goodBeamMap,code);
        
        %Decoding the corresponding codeword
                
        comma = strfind(code,',');
        clis = strfind(code,';');
        Nclis = 0;
        if(isempty(clis))
            Nclis = 1;
        else
            Nclis = max(size(clis)) + 1;
        end
        
        sword  = strfind(code,'|');
        patt_id = str2num(code(1:comma-1));
        lev = str2num(code(comma+1:sword-1));
        
        curr_bp = code(1:sword-1);
        
        current_widen = str2num(code(sword+1:end));

        %Check if any of these clients are already inside the widened
        %client list; If yes, then ignore this beam and go to next
               
        if(isempty(intersect(widened_clients,current_widen)))
            loc_min = min(RX_full_measure(lev,patt_id,current_widen));
            
            d_s_final = d_s_final + (L_min/DataRate(loc_min));
            widened_clients = [widened_clients; current_widen];
            
            %Deleting all keys with this pattern or clients
            for n=1:1:Nkeys
                code = keySet{n};
                sword = strfind(code,'|');
                clu = str2num(code(sword+1:end));
                if(strcmp(code(1:sword-1),curr_bp) || isempty(intersect(widened_clients,clu))==0)
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
                d_s_final = d_s_final + (L_min/DataRate(loc_min));
            end
        end        
    end
    
    if(valid == 1)
        d_s = d_s_final;
        %d_upto_cnt
    else
        d_s = d_s_finest;
    end

    %wir = d_s_finest/d_s_final

