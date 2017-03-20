s = serial('/dev/','BaudRate',57600);
fopen(s);
fprintf(s, 'xymm 1 10000xy');
fclose(s);
delete(s);
clear s;