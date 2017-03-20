function [d_s, Nbeams_lev] = beam_gen_aot(RX_measure_report, Beam_index_report,RX_full_measure)

    %ASCENDING ORDER TRAVERSAL
    %STRATEGY IS TO FIND THE NARROWEST BEAM FOR EACH CLIENT
    %IF WIDE BEAMS ARE USED, ASSIGN CLIENTS SERVABLE BY THIS BEAM
    %EVEN THOUGH THEY CANBE SERVED BY FINER BEAMS. THIS IS TO REDUCE
    %TRANSMISSION TIME
    %IF TWO WIDE BEAMS EACH OF SEPARATE LEVEL CAN SERVE A CLIENT, PICK THE WDER
    %ONE IF IT IS SERVING ANOTHER CLIENT NECESSARILY
    % RANDOM SELECTION OF WIDE BEAM AT SAME LEVEL FOR A CLIENT SERVABLE BY
    % EITHER AND THEM ACTUALLY NOT BEING THE CLIENT'S BEST BEAM AND THE CLIENT
    % HAS A FINER BEAM AS ITS BEST BEAM

    % I want to find out the level of best beam for each client

    d_s = 0;

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);
    
    Nbeams_lev = zeros(Nap_bw,1);
    
    %Finding the Best beam level available for each client
    best_level = zeros(N_u,1);
    for u=1:1:N_u
        for q=Nap_bw:-1:1
            if(Beam_index_report(q,u) ~= -1)
                best_level(u) = q;
                break;
            end
        end
    end

    %Client Assignment 
    assigned = [];
    not_assigned = 1:1:N_u;

    for q = Nap_bw:-1:1
        if(~isempty(find(best_level(not_assigned)==q)))
            main_clients = not_assigned(best_level(not_assigned)==q);        
            for c = 1:1:max(size(main_clients))           
                if(~isempty(find(not_assigned == main_clients(c))))
                    beam = Beam_index_report(q,main_clients(c));
                    served_clients = not_assigned(find(squeeze(RX_full_measure(q,beam,not_assigned)) >= P_RX_min));

                    loc_min = min(RX_full_measure(q,beam,served_clients));
                    D_curr = L_min/DataRate(loc_min);

                    Nbeams_lev(q) = Nbeams_lev(q) + 1;
                    
                    d_s = d_s + D_curr;
                    not_assigned = setxor(not_assigned,served_clients);
                    assigned = [assigned,served_clients];
                end
            end
        end
        
        if(isempty(not_assigned))
            break;
        end
    end

end

            
            
            
            
        
        
    



    

