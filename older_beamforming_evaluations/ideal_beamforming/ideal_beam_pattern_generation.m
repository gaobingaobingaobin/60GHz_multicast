close all;
clear all;
clc;

addpath('../tree_matlab/');
addpath('../export_fig/');

% This is the Beam Pattern Test script for Ideal Beam Patterns
% (Theoretical)

%Initial Wide beams are 120 deg each - so 3 beams at level 1
% Then branched into sub-levels of 2 beams each

N_T = 6;
N_br_0 = 3; %120 deg each
N_br = 2;
eta = 0.8;
Nang = 100;
th_ang = ((0:1:Nang-1)*2*pi/Nang);

N_br_max = N_br_0*(N_br^(N_T-1)); %At the lowest level, leaf nodes of tree

w_or = zeros(N_br_max,N_T); %Main Orientation of the Beam
AF = zeros(Nang,N_br_max,N_T);

b_T_0 = 2*pi/3;
b_T = b_T_0./N_br.^(0:1:N_T-1);

for q=1:1:N_T
    m_t(q) = N_br_0*(N_br^(q-1));
    for v=1:1:m_t(q)
        w_or(v,q) = (0.5*b_T(q)) + ((v-1)*b_T(q));
        
        % Array Factorization
        for ang=1:1:Nang
            beam_gain = 2*pi*eta/b_T(q);
            rx_dev = abs(th_ang(ang) - w_or(v,q));
            deviation_loss = 10^(1.2*((rx_dev/b_T(q))^2));
            AF(ang,v,q) = beam_gain/deviation_loss;
        end
    end
end

%% CODEBOOK TREE FORMATION
%Strategy is to go level by level and the tree node index will be iterated
%in the order of entry into the tree
%Value at each node will be in the form (i,j) - it represents (codebook
%level index, beam index in ith level)

%Creating the tree
cb_tree = tree('root'); %codebook tree
%Node index 1 as this is the first entry into the tree

%Creating the first level
for br=1:1:N_br_0
    cb_tree = cb_tree.addnode(1,['(1,' num2str(br) ')']);
end

%Now, do the correlation analysis
if(N_T > 1)
    for q=2:1:N_T
        for v=1:1:m_t(q)
            corr = zeros(m_t(q-1),1);
            g_q = squeeze(AF(v,q,:));
            
            %Identifying the best parent
            for x=1:1:m_t(q-1)
                g_q_higher = squeeze(AF(x,q-1,:));
                corr(x) = abs(g_q_higher'*g_q);
            end
            
            loc = find(corr == max(corr));
            
            for l=1:1:max(size(loc))
                parent_id = find(strcmp(cb_tree,['(' num2str(q-1) ',' num2str(loc(l)) ')']));
                if(max(size(cb_tree.getchildren(parent_id))) < N_br)
                    break;
                end
            end
            
            %Adding the node
            cb_tree = cb_tree.addnode(parent_id,['(' num2str(q) ',' num2str(v) ')']);
        end
    end
end
                
disp(cb_tree.tostring);
%save('ideal_codebook.mat');

% PLOTS 
%Plotting the Beam Patterns
cc = hsv(N_br_max);

for q = 1:1:N_T
    figure
    for v=1:1:m_t(q)
        h = polar(th_ang',squeeze(AF(:,v,q)));%,'color',cc(v,:));
        set(h,'color',cc(v,:));
        hold all;
    end
    title(['Beam Pattern for Codebook Level = ' num2str(q)]);
    set(gca,'FontSize',20,'fontWeight','bold');
    set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
end

