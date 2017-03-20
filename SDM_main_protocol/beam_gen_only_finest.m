function [d_s,Nbeams_lev] = beam_gen_only_finest(RX_measure_report, Beam_index_report)
%BEAM GROUP GENERATION USING FINEST BEAM TECHNIQUE

    load global_params_incr.mat;
    N_u = size(RX_measure_report,2);    
    d_s = 0;
    
    Nbeams_lev = zeros(Nap_bw,1);
    
%     for b=1:1:Ncodewords_bw(Nap_bw)
%         clients = find(squeeze(Beam_index_report(Nap_bw,:)) == b);
%         if(isempty(clients) == 0)
%             loc_min = min(RX_measure_report(Nap_bw,clients));
%             d_s = d_s + (L_min/DataRate(loc_min));
%         end
%     end
    
    for user=1:1:N_u
        pow = RX_measure_report(Nap_bw,user);
        d_s = d_s + (L_min/DataRate(pow));
        Nbeams_lev(Nap_bw) = Nbeams_lev(Nap_bw) + 1;
    end
    
end

