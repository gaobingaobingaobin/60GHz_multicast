clear all;
close all;
clc;

% === THIS CODE FOR Quantifying and Visualizing Non-Monotonicity 
% === in Codebook Trees

% Strategy:
% 10 different locs, 72 5-level codebook trees, 3 orientations

% For each loc, or, cb tree
% Best in level x-> code in x+1 level; Found in level x-> code in level x+1

addpath('../tree_matlab/');

load measures_and_trees_map.mat;
load global_params_incr.mat;

%% Finding the beam pattern index with highest exhaustive signal strength
highest_ID = zeros(Nap_bw,Ncodebooks,Nclient_locs,Nclient_ors);

% Servability
servable = zeros(Nap_bw,Ncodebooks,Nclient_locs,Nclient_ors);
servable_num = zeros(Nap_bw,Nclient_ors);
servable_den = zeros(Nap_bw,Nclient_ors);

% Monotonicity
highest_to_next = -1*ones(Nap_bw - 1,Ncodebooks,Nclient_locs,Nclient_ors); % -1 -> Not reachable; 0 -> No children; 1 -> Reachable
monotonic_num = zeros(Nap_bw-1,Nclient_ors);
monotonic_den = zeros(Nap_bw-1,Nclient_ors);

%Mismatch
mismatch_num = zeros(Nap_bw-1,Nclient_ors);
mismatch_den = zeros(Nap_bw-1,Nclient_ors);

for cb_id = 1:1:Ncodebooks
    cb_tree =  cb_trees{cb_id};
    
    cb_id
    
    for ap_bw = Nap_bw:-1:1
        
        ap_bw
        
        for client_loc = 1:1:Nclient_locs
            for client_or = 1:1:Nclient_ors
                [strength,best_beam] = max(squeeze(standard_pow_cb(cb_id,ap_bw,:,client_loc,client_or)));
                highest_ID(ap_bw,cb_id,client_loc,client_or) = best_beam;        
                
                servable_den(ap_bw,client_or) = servable_den(ap_bw,client_or) + 1;
                
                if(strength >= P_RX_min)
                    servable(ap_bw,cb_id,client_loc,client_or) = 1;
                    servable_num(ap_bw,client_or) = servable_num(ap_bw,client_or) + 1;
                end
                
                % HIGHEST TO NEXT LEVEL CHECK
                if(ap_bw < Nap_bw)
                    %Finding Children
                    parent_id = find(strcmp(cb_tree,['(' num2str(ap_bw) ',' num2str(best_beam) ')']));
                    children = cb_tree.getchildren(parent_id);

                    reached = 0;
                    rx_pow = -Inf;
                    rx_child_ind = -1;
                    
                    if(isempty(children)== 0)
                        monotonic_den(ap_bw,client_or) = monotonic_den(ap_bw,client_or) + 1;

                        for c=1:1:max(size(children))
                            code = cb_tree.get(children(c));
                            start = strfind(code,',') + 1;
                            fin = strfind(code,')')-1;
                            
                            % Beam pattern index of the children
                            ind = str2num(code(start:fin));
                            
                            if(standard_pow_cb(cb_id,ap_bw+1,ind,client_loc,client_or) >= P_RX_min)
                                highest_to_next(ap_bw,cb_id,client_loc,client_or) = 1;
                                if(reached == 0)
                                    monotonic_num(ap_bw,client_or) = monotonic_num(ap_bw,client_or) + 1;
                                    reached = 1;
                                end
                                
                                if(standard_pow_cb(cb_id,ap_bw+1,ind,client_loc,client_or) > rx_pow)
                                    rx_pow = standard_pow_cb(cb_id,ap_bw+1,ind,client_loc,client_or);
                                    rx_child_ind = ind;
                                end
                                
                            end
                        end
                        
                        mismatch_den(ap_bw,client_or) = mismatch_den(ap_bw,client_or) + 1;
                        
                        if(rx_child_ind == highest_ID(ap_bw+1,cb_id,client_loc,client_or))
                            mismatch_num(ap_bw,client_or) = mismatch_num(ap_bw,client_or) + 1;
                        end
                        
                    else
                        highest_to_next(ap_bw,cb_id,client_loc,client_or) = 0;
                    end
                end
            end
        end
    end
end

servability = zeros(Nclient_ors,1);
monotonicity = zeros(Nclient_ors,1);
mismatch = zeros(Nclient_ors,1);

for client_or = 1:1:Nclient_ors
    for ap_bw=1:1:Nap_bw
        servability(ap_bw,client_or) = servable_num(ap_bw,client_or)/servable_den(ap_bw,client_or);
        if(ap_bw < Nap_bw)
            monotonicity(ap_bw,client_or) = monotonic_num(ap_bw,client_or)/monotonic_den(ap_bw,client_or);
            mismatch(ap_bw,client_or) = mismatch_num(ap_bw,client_or)/mismatch_den(ap_bw,client_or);
        end
    end
end

%% PLOTS

legend_bw= {'LOS Link', 'NLOS Link'};

%SERVABLE DISTRIBUTION
figure(1);
colormap inferno;
y = 100*[servability(1,[1 2]); servability(2,[1 2]); servability(3,[1 2]); servability(4,[1 2]); servability(5,[1 2])];
bar(y)
legend(legend_bw);
xlabel('Codebook Level');
ylabel('SERVABILITY (%)');
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');

figure(2)
colormap inferno;
y = 100*[monotonicity(1,[1 2]); monotonicity(2,[1 2]); monotonicity(3,[1 2]);monotonicity(4,[1 2])];
bar(y)
legend(legend_bw);
xlabel('Codebook Level Change');
ylabel('MONOTONICITY (%)');
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');
Labels = {'1->2', '2->3', '3->4', '4->5'};
set(gca, 'XTick', 1:4, 'XTickLabel', Labels);

figure(3)
colormap inferno;
y = 100*[mismatch(1,[1 2]); mismatch(2,[1 2]); mismatch(3,[1 2]); mismatch(4,[1 2])];
bar(y)
legend(legend_bw);
xlabel('Codebook Level Change');
ylabel('BEST BEAM MATCH (%)');
set(gca,'FontSize',24,'fontWeight','bold');
set(findall(gcf,'type','text'),'FontSize',24,'fontWeight','bold');
Labels = {'1->2', '2->3', '3->4', '4->5'};
set(gca, 'XTick', 1:4, 'XTickLabel', Labels);

% legend_bw= {'80 DEGREE','20 DEGREE','7 DEGREE'};
% 
% cc = hsv(Nap_bw_trace);
% figure;
% for t=1:1:Nap_bw_trace
%      kk = squeeze(rms_norm_pow_trace(client_loc,client_or,t,:));
%      kk = circshift(kk,Ncirc_shift);
%      plot(set_ant_angle,kk,'color',cc(t,:));
%      %errorbar(1:Nclient_locs,squeeze(tr_oh_res(:,t,1)),squeeze(tr_oh_res(:,t,2)),'color',cc(t,:));
%      hold all;
% end
% title(['Client Location = ' num2str(client_loc) ' Client Or = ' num2str(client_or)]);
% xlabel('AP Orientation Angle (degrees) ---->');
% ylabel('Normalized Power --->');
% legend(legend_bw);
% set(gca,'FontSize',20,'fontWeight','bold');
% set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');



