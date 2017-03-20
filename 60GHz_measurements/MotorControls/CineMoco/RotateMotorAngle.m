function RotateMotorAngle(MySerial,curAngle,newAngle)

angleDiff = newAngle - curAngle;
numSteps = round(angleDiff/0.01125)
command=['xymm 1 ',num2str(numSteps),'xy'];%xy is the serial terminator
fprintf(MySerial, command);