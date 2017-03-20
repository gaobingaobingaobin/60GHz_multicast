function GoToAngle(Port,currentAngleDegrees,newAngle)

%=============
% Calculate needed motion to get to new angle
%=============

if(currentAngleDegrees < 0 || newAngle <0)
    error('Angles must be positive'); 
end

currentAngleDegrees = mod(currentAngleDegrees,360);
newAngle = mod(newAngle,360);

shift = newAngle-currentAngleDegrees;
if(newAngle > 180 && currentAngleDegrees <= 180)
    Degrees = -360+shift;
%     dir = 'ccw';
else
    if(newAngle < 180 && currentAngleDegrees >=180)
        Degrees = 360+shift;
%         dir = 'cw';
    else
        Degrees = shift;
%         if(Degrees < 0)
%             dir = 'ccw';
%         else
%             dir = 'cw'; 
%         end
    end
end

if(Degrees < 0)
    Degrees = -Degrees;
    dir = 'ccw';
else
    dir = 'cw';
end

%=============
% Set up Communication Protocol
%=============
s = serial(Port); % Create Serial Object
s.terminator = 'CR';
% set(s,'BaudRate',9600);
% disp(s)

% =============
%Serial Comunication
%=============
% % Open Communication
fopen(s)
% disp(s)

distance=556*Degrees
% waittime=sprintf('WT%d',timesec)
if  strcmp(dir,'cw')
    movement=sprintf('DI%d',distance)
elseif strcmp(dir,'ccw')
    movement=sprintf('DI-%d',distance)
end

fprintf(s, 'VE1')
fprintf(s, movement)
fprintf(s, 'FL200000')

% %Close Communication
fclose(s)
delete(s)
clear s
end