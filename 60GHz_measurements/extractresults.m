Parameters;


angleStep = 5;

set_ant_angle	= -180:angleStep:175; %-180:5:175; 
set_BBgain		= [1]; % Not used actually

set_iterations	=10;

thresh=0.005;

set_modIndex	= [2];
set_fsamp		= [5e6];

%Compile all matricies

%     addpath('./matlab2tikz/src/');

     %Get RMS statistics
     myRMS = cellfun(@(x) x.rms,results); %Convert all structures to RMS
     rmsMean = mean(myRMS,5);
     rmsSTDEV = std(myRMS,0,5);
     bpskRmsMean = rmsMean(:,1,1); %numAngles x 1 matrix
     bpskRmsStd = rmsSTDEV(:,1,1); %numAngles x 1 matrixw
     
     %Get BER statistics
     myBER = cellfun(@(x) x.ber,results);
     berMean = mean(myBER,5);
     bpskBerMean = berMean(:,1,1);
%      qpskBerMean = berMean(:,1,2);
%      qam16BerMean = berMean(:,1,3);
     
     %Plot results
     myfig=figure;
     
     subplot(2,2,1);
     plot(set_ant_angle,bpskRmsMean);
     xlabel('Tx Antenna Angle (Degrees)');
     ylabel('RSS in RMS Volts');
     title('RSS Plot for BPSK');
     hold on;
     subplot(2,2,2);
%      plot(set_ant_angle,(max(bpskBerMean)-bpskBerMean)/max(bpskBerMean));
     plot(set_ant_angle,bpskBerMean);
     xlabel('Tx Antenna Angle (Degrees)');
     ylabel('BER');
     title('BER Plot for BPSK');
     hold on;
     subplot(2,2,3);
%      plot(set_ant_angle,(max(qpskBerMean)-qpskBerMean)/max(qpskBerMean));
%      plot(set_ant_angle,qpskBerMean);
%      xlabel('Tx Antenna Angle (Degrees)');
%      ylabel('BER');
%      title('BER Plot for QPSK');
%      hold on;
%      subplot(2,2,4);
% %      plot(set_ant_angle,(max(qam16BerMean)-qam16BerMean)/max(qam16BerMean));
%      plot(set_ant_angle,qam16BerMean);
%      xlabel('Tx Antenna Angle (Degrees)');
%      ylabel('BER');
%      title('BER Plot for 16QAM');
     
     %%
     %Make box plots
     bpskber=reshape(myBER(:,:,1,:,:),length(set_ant_angle),set_iterations);
%      qpskber=reshape(myBER(:,:,2,:,:),length(set_ant_angle),set_iterations);
%      qam16ber=reshape(myBER(:,:,3,:,:),length(set_ant_angle),set_iterations);
     
     figure;
     subplot(3,1,1);
     boxplot(bpskber',set_ant_angle);
     xlabel('Tx Angle (Degrees)');
     ylabel('BER');
     title('BPSK BER');
     hold on;
%      subplot(3,1,2);
%      boxplot(qpskber',set_ant_angle,'plotstyle','compact');
%      xlabel('Tx Angle (Degrees)');
%      ylabel('BER');
%      title('4QAM BER');
%      hold on;
%      subplot(3,1,3);
%      boxplot(qam16ber',set_ant_angle,'plotstyle','compact');
%      xlabel('Tx Angle (Degrees)');
%      ylabel('BER');
%      title('16QAM BER');
     
          %%
     %Narrow boxplots
     
     narrowbox=figure;
%     angleasstring = mat2cell(set_ant_angle(1+90/5:end-85/5),1,ones(1,numel(set_ant_angle(1+90/5:end-85/5))));
%     angleasstring = cellfun(@(x) num2str(x),angleasstring,'UniformOutput',0);
%      narrowbox=tikz_boxplot(bpskber(1+90/5:end-85/5,:)',anglesasstring,'Tx Azimuth Orientation (Degrees)');
     boxplot(bpskber',set_ant_angle,'plotstyle','compact');
     xlabel('Tx Angle (Degrees)');
     ylabel('BER');
     title('BPSK BER');
%      saveFigure(narrowbox,'narrowbox');
     
     %%
     %RSS for BPSK with line
     rss=figure;
     rssthres=0.15;
     mymax=max(bpskRmsMean);
%      errorbar(set_ant_angle(1+90/5:end-85/5),(bpskRmsMean(1+90/5:end-85/5))/mymax,1.96*bpskRmsStd(1+90/5:end-85/5)/sqrt(50));
     errorbar(set_ant_angle,bpskRmsMean,1.96*bpskRmsStd);
     xlabel('Tx Azimuth Orientation (Degrees)');
     ylabel('Received Baseband RMS Voltage');
     axis([-180 180 0 0.7]);
%      title('Normalized RSS Plot for Verifier Sweep');
     hold on;
%      plot(set_ant_angle(1+90/5:end-85/5),rssthres*ones(length(set_ant_angle(1+90/5:end-85/5)),1),'-r');
%      saveFigure(rss,'rss');