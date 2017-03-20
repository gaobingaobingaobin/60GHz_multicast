close all;
clear all;
clc;

% THIS SCRIPT IS FOR GETTING THE OPTIMAL SUBSPREAD ANGLE FOR EACH CODEBOOK
% LEVEL

lambda = 0.005;
d = lambda/2;
M = 128; %M_T = M_R = M
N_B = 4;
K = 1 + floor(log(M)/log(N_B));
%K= 2*M; 
%k = 0;%ceil(K*rand);
%th_sp = 1.4*(2*pi/360); %4 degrees
N_ang = 100;
th_loc_range = pi;
N_sp = 1;
total_sp_range = 3;

% Adaptive Beamwidth Codebook Beam Pattern Generation
th_sq = zeros(M,1);
th_ang = (-pi/2) + ((0:1:N_ang-1)*pi/N_ang);
th_sp = 1.75;%1 + (total_sp_range/N_sp)*(0:1:N_sp-1);

del_sp = zeros(K,N_sp);
%P_all = NaN(N_or(k+1),N_ang

for k=0:1:K-1
    k
    N_or(k+1) = N_B^(k+1);
    N_sub(k+1) = M/(N_B^k); %Number of sub-arrays
    BW(k+1)= 4*pi*N_sub(k+1)/M;

    %Orientation of beam patterns
    th_or = (0:1:N_or(k+1)-1)*2*pi/N_or(k+1);
      
    del = NaN(N_sp,1);
    
    for sp=1:1:N_sp
        sp
        %Squinting angle generation
        th_sq = (ceil((1:1:M)*N_sub(k+1)/M) - ((N_sub(k+1)+1)/2))*th_sp(sp);
        
        W = NaN(M,N_or(k+1));
        W_sw = NaN(M,N_or(k+1));
        B = zeros(N_or(k+1),N_ang);
        P = NaN(N_or(k+1),N_ang);
        
        %Codebook beam vector generation
        for or=1:1:N_or(k+1)   
            for m=0:1:M-1 
                %BASIC CODEBOOK 
                %W(m+1,or)=(1i^(floor(m*mod(k+K/2,K)/(K/4))))*exp(sqrt(-1)*(m)*th_or(or));

                %MULTI-LEVEL CODEBOOK
                W(m+1,or) = (1/sqrt(M))*exp(-sqrt(-1)*m*(th_sq(m+1)+ th_or(or)));
            end

            %Spectral Windowing
            temp = W(:,or).*taylorwin(M);
            W_sw(:,or) = temp/(norm(temp));

            %Array Gain Computation
            for ang=1:1:N_ang
                th_ang(ang) = (-1*th_loc_range/2) + ((ang-1)*th_loc_range/N_ang);
                for m=0:1:M-1
                    B(or,ang) = B(or,ang) + (W_sw(m+1,or)*(exp(sqrt(-1)*m*pi*sin(th_ang(ang)))));
                end
                %P(k+1,ang) = P_T + 20*log10(abs(M*(B(k+1,ang)^2)));
                P(or,ang) = abs(B(or,ang)^2);
            end
        end
        
        %COVERING DISTANCE COMPUTATION
        inner = max(P,[],1);
        X = min(inner);
        del(sp) = sqrt(1 - (X/M));
        del_sp(k+1,sp) = del(sp);
    end

    [~,ind] = min(del);
    
    opt_sp_ind(k+1) = ind;
    opt_sp(k+1) = th_sp(ind);
end

% GENERATING THE BEAM PATTERNS FOR OPTIMAL SUBSPREAD ANGLES OF EACH
% CODEBOOK LEVEL

W_opt = NaN(M,K,N_or(K));
W_sw_opt = NaN(M,K,N_or(K));
B_opt = zeros(N_or(K),K,N_ang);
P_opt = zeros(N_or(K),K,N_ang);

for k=0:1:K-1
    k
    th_or = (0:1:N_or(k+1)-1)*2*pi/N_or(k+1);
    th_sq = (ceil((1:1:M)*N_sub(k+1)/M) - ((N_sub(k+1)+1)/2))*th_sp(opt_sp_ind(k+1));

    %Codebook beam vector generation
    for or=1:1:N_or(k+1)   
        for m=0:1:M-1 
            %BASIC CODEBOOK 
            %W(m+1,or)=(1i^(floor(m*mod(k+K/2,K)/(K/4))))*exp(sqrt(-1)*(m)*th_or(or));

            %MULTI-LEVEL CODEBOOK
            W_opt(m+1,k+1,or) = (1/sqrt(M))*exp(-sqrt(-1)*m*(th_sq(m+1)+ th_or(or)));
        end

        %Spectral Windowing
        temp = W_opt(:,k+1,or).*taylorwin(M);
        W_sw_opt(:,k+1,or) = temp/(norm(temp));

        %Array Gain Computation
        for ang=1:1:N_ang
            for m=0:1:M-1
                B_opt(or,k+1,ang) = B_opt(or,k+1,ang) + (W_sw_opt(m+1,k+1,or)*(exp(sqrt(-1)*m*pi*sin(th_ang(ang)))));
            end
            %P(k+1,ang) = P_T + 20*log10(abs(M*(B(k+1,ang)^2)));
            P_opt(or,k+1,ang) = abs(B_opt(or,k+1,ang)^2);
        end
    end
end

save('subspread_optimized_codebook.mat');

% %Plotting the Beam Patterns
% cc = hsv(N_or);%hsv(max(3,N_or));
% legend_K = eval(['{' sprintf('''Orientation = %d'' ',1:1:N_or) '}']);
% 
% figure;
% for or=1:1:N_or
%     h = polar(th_ang',P(or,:));%,'color',cc(k,:));
%     set(h,'color',cc(or,:));
%     %pause(3.0);
%     hold all;
% end
% 
% title(['Single-Level Codebook Beam Pattern Generation K = ' num2str(k)]);
% xlabel('Angles (radians)');
% ylabel('Array Gain (dB)');
% legend(legend_K);
% set(gca,'FontSize',20,'fontWeight','bold');
% set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');


        
