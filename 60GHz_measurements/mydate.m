classdef mydate 
%This is the first class I create in MATLAB

    properties
        % define the properties of the class here, (liek fields of a
        % struct)
        minute = 0;
        hour;
        day;
        month;
        year;
    end
    
    methods
        % methods, including the constructor are defined in this block
        
        function obj = mydate(minute,hour,day,month,year)
            % class constructor
            if(nargin > 0)
                obj.minute = minute;
                obj.hour = hour;
                obj.day = day;
                obj.month = month;
                obj.year = year;
            end
        end
        
        function obj = rollDay(obj,numdays)
            obj.day = obj.day + numdays;
        end
    end
end