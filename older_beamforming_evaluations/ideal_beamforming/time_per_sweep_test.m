clear all;
clc;
close all;

initialize_static;

for k=1:1:max(size(sense_thresh_SC))
    time_min(k) = L_min/DataRate(sense_thresh_SC(k));
    time_max(k) = L_max/DataRate(sense_thresh_SC(k));
end

plot(time_min);
title('Small Packet');

figure;
plot(time_max);
title('Large Packet');