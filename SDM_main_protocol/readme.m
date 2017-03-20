%THIS FOLDER INCLUDE ALL FILES USED FOR SIMULATION FOR SECON 2016 PAPER
%THE TRACES OF SIGNAL STRENGTH MEASUREMENTS WERE COLLECTED IN DUNCAN HALL
%FISH BOWL 
% 10 different client locations, 3 different orientations separated by 60
% deg. The AP side sweep was performed for 5 degree separation
%THESE MEASUREMENTS WERE CONVERTED TO 11AD MCS RX Power by 1. normalizing
%based on maximum value 2. Using -53 dBm which is the RX power for highest
%data rate using SC-PHY as the value for normalized value of 1.
%As 5 degree separation has 72 points spread out over 360, the codebook
%could use any of these points as 0 degree. So, 72 different codebook trees
%were generated with 3 levels [80deg 20 deg and 7 deg]. The trees were
%constructed using the ideal beam pattern and deviation loss for not being
%in the main direction of beam.

%In the evaluation, we will be changing the number of clients in the
%network - they will be selected from the toal client positions and
%orientations and all possible codebook trees will be evaluated

