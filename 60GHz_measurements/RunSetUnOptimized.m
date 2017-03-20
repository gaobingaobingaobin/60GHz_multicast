%% RunSet.m
% Executes a set of transmission and plots the results

% Initlialize the environment

addpath(genpath('./MotorControls/'));

pause(5);

Initialize;
exectimer = tic;
disp('Evaluation mode: Set transmission');

% Set up the default parameters
disp('Setting default parameters:');
Parameters;

swp_flag = 1; % 1 = TX_SWEEP; 2 - RX_SWEEP

% Set up the variable parameters
motorCom = 'COM5';
if(swp_flag == 2)
  motorCom = 'COM11';
  MySerial = OpenMotor(motorCom);
end
angleStep = 5;

set_ant_angle	= -180:angleStep:175; %-180:5:175; 
set_BBgain		= [1]; % Not used actually

set_iterations	=10;

thresh=0.005;

set_modIndex	= [2];
set_fsamp		= [5e6];

% constellation = figure;

cur_angle = 0;

% Initialize the resuls parameters
results = cell(	length(set_ant_angle), ...
    length(set_BBgain), ...
    length(set_modIndex), ...
    length(set_fsamp), ...
    set_iterations);

% iterate over all parameters
for k_angle = 1:length(set_ant_angle)
    par.rx_angle = set_ant_angle(k_angle);
    
    if(swp_flag == 1)
        %Set the antenna angle
        if par.rx_angle < 0;
            my_angle = 360 + par.rx_angle;
        else
            my_angle = par.rx_angle;
        end

        GoToAngle(motorCom, cur_angle, my_angle); 
    
        if(k_angle ==1)
            pause(5);
        else
            pause(1); %1 seconds is long enough for short movements
        end
        if(par.rx_angle == set_ant_angle(2)) %Extra time is needed to get from -180 degrees to -175 deg
            pause(8); 
        end
    else
        my_angle = par.rx_angle;
        RotateMotorAngle(MySerial,set_ant_angle(1),my_angle);
        pause(5);
    end
    cur_angle = my_angle;
    
    for k_bbgain = 1:length(set_BBgain)
        par.bbGain = set_BBgain(k_bbgain);
        
        % Set the antenna gains on VubIQ
        %setgains(15,15,par.bbGain);
        
        for k_modind = 1:length(set_modIndex)
            par.modIndex = set_modIndex(k_modind);
            
            for k_fsamp = 1:length(set_fsamp);
                par.fsamp = set_fsamp(k_fsamp);
                
                % Set the transmission constants
                SetTransmissionConstants;
                noise_flag=0;
                for k_it = 1:set_iterations;
                    
                    % Display the parameters
                    disp(par);
                    
                    % Execute the experiment
                    while true
                        try
                            TransmissionOld;
                            break;
                        catch err
                            disp('Error in transmission, repeating');
                            disp(err);
                        end
                    end
                    
                    % Close the WARPLab sockets
                    pnet('closeall');
                    
                    % State the results
                    disp('Obtaining results:');
                    disp(res);

                    % Store the results
                    results{k_angle, k_bbgain, k_modind, k_fsamp, k_it} ...
                        = res;
                   
                end
                save ('temp.mat','results')
            end
        end
    end
end

if(swp_flag == 1)
    GoToAngle(motorCom, cur_angle, 0);
else
    RotateMotorAngle(MySerial,cur_angle,0);
    CloseMotor(MySerial)
end

% Visualize the transmission
dur  = toc(exectimer);
disp(['Experiment finished, needed ', num2str(dur), 's to complete.']);

beep;




