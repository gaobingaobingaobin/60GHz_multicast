close all;
clear all;
clc;

% THIS SCRIPT IS THE FIRST TRIAL OF MULTI-LEVEL BEAMFORMING

lambda = 0.005;
d = lambda/2;
M = 128; %M_T = M_R = M

N_B = 4;
K = 1 + floor(log(M)/log(N_B));
%K = M;

%N_B_o = 4;
%N_B = 2;
%K = 1 + floor(log(M/N_B_o)/log(N_B));

th_sp = 1*(2*pi/360); %4 degrees
N_ang = 100;
N_or = 1;
P_T = 10; %dBm

% Adaptive Beamwidth Codebook Beam Pattern Generation
th_sq = zeros(M,K);

N_or = N_B.^(1:1:K);
N_sub = M./(N_B.^(0:1:K-1)); %Number of sub-arrays
BW = 4*pi*N_sub/M;
W_opt = NaN(M,K,N_or(K));
W_sw_opt = NaN(M,K,N_or(K));
B_opt = zeros(N_or(K),K,N_ang);
P_opt = NaN(N_or(K),K,N_ang);
th_ang = (-pi/2) + ((0:1:N_ang-1)*pi/N_ang);


cc = hsv(max(3,2*K));
legend_K = eval(['{' sprintf('''Level = %d'' ',1:1:K) '}']);
%figure;

for k=0:1:K-1
    k
    

    %Orientation of beam patterns
    th_or = (0:1:N_or(k+1)-1)*2*pi/N_or(k+1);
    
    %N_sub = M/(N_B_o*N_B^(k)) %Number of sub-arrays
    BW_k(k+1) = 2*360*N_sub(k+1)/M;
    
    %=th_or = k*pi/K;
    
    %Squinting angle for k-th level and m-th antenna element
    th_sq = (ceil((1:1:M)*N_sub(k+1)/M) - ((N_sub(k+1)+1)/2))*th_sp;
    
    W = NaN(M,N_or(k+1));
    W_sw = NaN(M,N_or(k+1));
    B = zeros(N_or(k+1),N_ang);
    P = NaN(N_or(k+1),N_ang);
    
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
            for m=0:1:M-1
                B(or,ang) = B(or,ang) + (W_sw(m+1,or)*(exp(sqrt(-1)*m*pi*sin(th_ang(ang)))));
            end
            %P(k+1,ang) = P_T + 20*log10(abs(M*(B(k+1,ang)^2)));
            P(or,ang) = abs(B(or,ang)^2);
        end
    end
    
    cc = hsv(N_or(k+1));
    figure
    for or=1:1:N_or(k+1)
        h = plot(th_ang',squeeze(P(or,:)));%,'color',cc(k,:));
        set(h,'color',cc(or,:));
        %pause(3.0);
        hold all;
    end
    
    W_opt(:,k+1,1:N_or(k+1)) = W;
    W_sw_opt(:,k+1,1:N_or(k+1)) = W_sw;
    B_opt(1:N_or(k+1),k+1,:) = B;
    P_opt(1:N_or(k+1),k+1,:) = P;
    
end

save('subspread_optimized_codebook.mat');

% %Plotting the Beam Patterns
% cc = hsv(max(3,2*K));
% legend_K = eval(['{' sprintf('''Level = %d'' ',1:1:K) '}']);
% 
% figure;
% for k=1:1:K
%     h = plot(th_ang',P(k,:));%,'color',cc(k,:));
%     set(h,'color',cc(2*k,:));
%     hold all;
% end
% 
% title('Multi-Level Codebook Beam Pattern Generation');
% %xlabel('Angles (degrees)');
% %ylabel('Array Gain (dB)');
% legend(legend_K);
% set(gca,'FontSize',20,'fontWeight','bold');
% set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');


% %Plotting the Squinting Angle
% 
% figure;
% for k=1:1:K
%     hold on;
%     plot(360*th_sq(k,:)/(2*pi),'color',cc(k,:));
% end
% title('Squinting Angle Distribution for Different Levels');
% xlabel('Antenna Element Index');
% ylabel('Angle(Degrees)');
% legend(legend_K);
% set(gca,'FontSize',20,'fontWeight','bold');
% set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');


        
