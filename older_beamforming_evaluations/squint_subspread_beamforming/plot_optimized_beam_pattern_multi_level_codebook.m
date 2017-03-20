s%Plotting the Beam Patterns
close all;

for k=0:1:K-1
    cc = hsv(N_or(k+1));%hsv(max(3,N_or));
    legend_K = eval(['{' sprintf('''Orientation = %d'' ',1:1:N_or(k+1)) '}']);

    %figure;
    for or=1:1:N_or(k+1)
        h = polar(th_ang',squeeze(P_opt(or,k+1,:)));%,'color',cc(k,:));
        set(h,'color',cc(or,:));
        %pause(3.0);
        hold all;
    end

%     title(['Single-Level Codebook Beam Pattern Generation K = ' num2str(k)]);
%     xlabel('Angles (radians)');
%     ylabel('Array Gain (dB)');
%     legend(legend_K);
%     set(gca,'FontSize',20,'fontWeight','bold');
%     set(findall(gcf,'type','text'),'FontSize',20,'fontWeight','bold');
end