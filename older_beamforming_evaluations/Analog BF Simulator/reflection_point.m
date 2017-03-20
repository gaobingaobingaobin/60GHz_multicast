% find reflection points
function reflection_location=reflection_point(TX_location,RX_location,room_size)
%TX_location=[1 1];
%RX_location=[6 5];
%room_size=[10 10];

reflection_location=zeros(4,2);

TX_mirror=TX_location;
TX_mirror(1)=-TX_mirror(1);
x1=TX_mirror(1);   y1=TX_mirror(2);
x2=RX_location(1); y2=RX_location(2);
k=(y2-y1)/(x2-x1);
b=y1-(y2-y1)/(x2-x1)*x1;
reflection_location(1,:)=[0 k*0+b];
                                     
TX_mirror=TX_location;
TX_mirror(2)=-TX_mirror(2);
x1=TX_mirror(1);   y1=TX_mirror(2);
x2=RX_location(1); y2=RX_location(2);
k=(y2-y1)/(x2-x1);
b=y1-(y2-y1)/(x2-x1)*x1;
reflection_location(2,:)=[-b/k 0];

TX_mirror=TX_location;
TX_mirror(1)=2*room_size(1)-TX_mirror(1);
x1=TX_mirror(1);   y1=TX_mirror(2);
x2=RX_location(1); y2=RX_location(2);
k=(y2-y1)/(x2-x1);
b=y1-(y2-y1)/(x2-x1)*x1;
reflection_location(3,:)=[room_size(1) k*room_size(1)+b];

TX_mirror=TX_location;
TX_mirror(2)=2*room_size(2)-TX_mirror(2);
x1=TX_mirror(1);   y1=TX_mirror(2);
x2=RX_location(1); y2=RX_location(2);
k=(y2-y1)/(x2-x1);
b=y1-(y2-y1)/(x2-x1)*x1;
reflection_location(4,:)=[(room_size(2)-b)/k room_size(2)];

