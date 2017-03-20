clear all;
close all;
clc;


addpath('../tree_matlab/');
addpath('../export_fig/');

%This file compiles the results of all client positions, orientations and
% transmit beamwidths into one file with projected 802.11ad RX power
% measure obtained by firstly the normalized rms rx power then using the
% highest power measure as the 802.11ad RX pwoer for best data rate using
% SC-PHY modulation

Nclient_locs = 10;
Nclient_ors = 3;
Nap_bw_trace= 3;
AP_bw_trace = [80 20 7];
AP_bw = [80 40 20 10 5];
Nap_bw = 5;

angleStep = 5;
set_ant_angle = 0:angleStep:355; %-180:5:175; 
set_iterations = 10;

Ncodebooks = max(size(set_ant_angle));
Ncodewords_bw = ceil(360./AP_bw);

rms_abs_pow_trace = NaN(Nclient_locs,Nclient_ors,Nap_bw_trace,max(size(set_ant_angle)));


for client_loc = 1:1:Nclient_locs
    for client_or =1:1:Nclient_ors
        for ap_bw = 1:1:Nap_bw_trace
            filename =['measurements/Pos_' num2str(client_loc) '_RX_or_' num2str(client_or) '_TX_deg_' num2str(AP_bw_trace(ap_bw)) '.mat'];
            load(filename);
            myRMS = cellfun(@(x) x.rms,results); %Convert all structures to RMS
            rmsMean = mean(myRMS,5);
            
            rms_abs_pow_trace(client_loc,client_or,ap_bw,1:max(size(rmsMean))) = rmsMean;
        end
    end
end

[max_val, position] = max(rms_abs_pow_trace(:));
rms_norm_pow_trace = rms_abs_pow_trace/max_val;



rms_abs_pow = NaN(Nclient_locs,Nclient_ors,Nap_bw,max(size(set_ant_angle)));

for ap_bw=1:1:Nap_bw
    bw_ind = find(AP_bw_trace <= AP_bw(ap_bw),1,'first');
    if(isempty(bw_ind) == 0)
       rms_abs_pow(:,:,ap_bw,:) = (AP_bw_trace(bw_ind)/AP_bw(ap_bw))*rms_abs_pow_trace(:,:,bw_ind,:);
    else
        rms_abs_pow(:,:,ap_bw,:) = (AP_bw_trace(Nap_bw_trace)/AP_bw(ap_bw))*rms_abs_pow_trace(:,:,Nap_bw_trace,:);
    end
end

%Finding the absolute maximum and absolute minimum
%# finds the max of A and its position, when A is viewed as a 1D array
[max_val, position] = max(rms_abs_pow(:));

[min_val, position] = min(rms_abs_pow(:));

%#transform the index in the 1D view to 4 indices, given the size of A
[max_i,max_j,max_k,max_l] = ind2sub(size(rms_abs_pow),position);
            
%Normalization of data
rms_norm_pow = rms_abs_pow/max_val;

%CONSTRUCTING CODEBOOK RECEIVED POWER MAPS
norm_pow_cb = NaN(Ncodebooks,Nap_bw,max(Ncodewords_bw),Nclient_locs,Nclient_ors);
standard_pow_cb = NaN(Ncodebooks,Nap_bw,max(Ncodewords_bw),Nclient_locs,Nclient_ors);

P_rx_max = -53; %dBm for highest data rate in 802.11ad standard
w_or = NaN(Ncodebooks,Nap_bw,max(Ncodewords_bw));
Nang = 100;
th_ang = ((0:1:Nang-1)*360/Nang);
eta = 0.8;
AF = zeros(Ncodebooks,max(Ncodewords_bw),Nap_bw,Nang);

for cb = 1:1:Ncodebooks
    initial_angle = set_ant_angle(cb);
    
    for ap_bw=1:1:Nap_bw
        for cw = 1:1:Ncodewords_bw(ap_bw)
            cw_dir = mod(initial_angle + ((cw-1)*AP_bw(ap_bw)) + (0.5*AP_bw(ap_bw)), 360);
            w_or(cb,ap_bw,cw) = cw_dir;
            
            % Array Factorization of the Codewords in the Codebook Trees
            for ang=1:1:Nang
                beam_gain = 360*eta/AP_bw(ap_bw);
                rx_dev = abs(th_ang(ang) - w_or(cb,ap_bw,cw));
                deviation_loss = 10^(1.2*((rx_dev/AP_bw(ap_bw))^2));
                AF(cb,cw,ap_bw,ang) = beam_gain/deviation_loss;
            end

            ix = find(set_ant_angle <= cw_dir,1,'last');
            
            if(set_ant_angle(ix) == cw_dir)
                prefix = 1;
            else
                prefix = (cw_dir - set_ant_angle(ix))/angleStep;
            end
            suffix = 0;
            
            for client_loc = 1:1:Nclient_locs
                for client_or = 1:1:Nclient_ors
                    norm_pow_cb(cb,ap_bw,cw,client_loc,client_or) = (prefix*rms_norm_pow(client_loc,client_or,ap_bw,ix));
                    if(suffix > 0)
                      norm_pow_cb(cb,ap_bw,cw,client_loc,client_or) = norm_pow_cb(cb,ap_bw,cw,client_loc,client_or) + (suffix*rms_norm_pow(client_loc,client_or,ap_bw,mod(ix+1,Ncodebooks)));
                    end
                    
                    standard_pow_cb(cb,ap_bw,cw,client_loc,client_or) = P_rx_max + (10*log10(norm_pow_cb(cb,ap_bw,cw,client_loc,client_or)));
                end
            end
        end
    end
end

%CODEBOOK TREE FORMATION

for cb=1:1:Ncodebooks
    cb
    %Creating the tree
    cb_tree = tree('root'); %codebook tree
    %Node index 1 as this is the first entry into the tree

    %Creating the first level
    for br=1:1:Ncodewords_bw(1)
        cb_tree = cb_tree.addnode(1,['(1,' num2str(br) ')']);
    end

    %Now, do the correlation analysis
    if(Nap_bw > 1)
        for ap_bw=2:1:Nap_bw
            for cw=1:1:Ncodewords_bw(ap_bw)

                found = 0;
%                 %BASIC MAIN DIRECTION OVERLAP TECHNIQUE
%                  for x=1:1:Ncodewords_bw(ap_bw-1)
%                      if(mod(w_or(cb,ap_bw-1,x) - (0.5*AP_bw(ap_bw-1)),360) < mod(w_or(cb,ap_bw-1,x) + (0.5*AP_bw(ap_bw-1)),360))
%                          if((w_or(cb,ap_bw-1,x) - (0.5*AP_bw(ap_bw-1)) <= w_or(cb,ap_bw,cw)) && (w_or(cb,ap_bw-1,x) + (0.5*AP_bw(ap_bw-1)) >= w_or(cb,ap_bw,cw)))
%                              found =1;
%                              break;
%                          end
%                      else
%                          if((w_or(cb,ap_bw-1,x) - (0.5*AP_bw(ap_bw-1)) <= w_or(cb,ap_bw,cw)) || (w_or(cb,ap_bw-1,x) + (0.5*AP_bw(ap_bw-1)) >= w_or(cb,ap_bw,cw)))
%                              found = 1;
%                              break;
%                          end
%                      end
%                  end
%                  
%                  if(found == 1)
%                      parent_id = find(strcmp(cb_tree,['(' num2str(ap_bw-1) ',' num2str(x) ')']));
%                      %Adding the node
%                      cb_tree = cb_tree.addnode(parent_id,['(' num2str(ap_bw) ',' num2str(cw) ')']);
%                  end
                
                         
                %ARRAY FACTOR CORRELATION TECHNIQUE
                corr = zeros(Ncodewords_bw(ap_bw-1),1);
                g_q = squeeze(AF(cb,cw,ap_bw,:));

                %Identifying the best parent
                for x=1:1:Ncodewords_bw(ap_bw-1)
                    g_q_higher = squeeze(AF(cb,x,ap_bw-1,:));
                    corr(x) = abs(g_q_higher'*g_q);
                end

%                 ap_bw
%                 cw
                loc = find(corr == max(corr));
%                 corr

                for l=1:1:max(size(loc))
                    parent_id = find(strcmp(cb_tree,['(' num2str(ap_bw-1) ',' num2str(loc(l)) ')']));
                    if(max(size(cb_tree.getchildren(parent_id))) < ceil(AP_bw(ap_bw-1)/AP_bw(ap_bw)))
                        break;
                    end
                end
                
                %Adding the node
                cb_tree = cb_tree.addnode(parent_id,['(' num2str(ap_bw) ',' num2str(cw) ')']);
                
            end
        end
    end
    disp(cb_tree.tostring);
    cb_trees{cb} = cb_tree;
    clear cb_tree;
end           

save('measures_and_trees_map.mat');



                
%                  %BASIC MAIN DIRECTION OVERLAP TECHNIQUE
%                  for x=1:1:Ncodewords_bw(ap_bw-1)
%                      ap_bw
%                      cw
%                      x
%                      p = w_or(cb,ap_bw-1,x)
%                      q = w_or(cb,ap_bw,cw)
%                      if((w_or(cb,ap_bw-1,x) - (0.5*AP_bw(ap_bw-1)) <= w_or(cb,ap_bw,cw)) && (w_or(cb,ap_bw-1,x) + (0.5*AP_bw(ap_bw-1)) >= w_or(cb,ap_bw,cw)))
%                          parent_id = find(strcmp(cb_tree,['(' num2str(ap_bw-1) ',' num2str(x) ')']));
%                          %Adding the node
%                          cb_tree = cb_tree.addnode(parent_id,['(' num2str(ap_bw) ',' num2str(cw) ')']);
%                          break;
%                      end
%                  end
%             end
%         end
%     end



                    
            


            