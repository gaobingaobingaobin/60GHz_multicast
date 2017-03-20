function MySerial = OpenMotor(motorCom)

MySerial = serial('COM11','BaudRate',57600);
fopen(MySerial);

dummy=input('Please reconnect Cinemoco');

command=['xymm 1 0xy'];
fprintf(MySerial, command);