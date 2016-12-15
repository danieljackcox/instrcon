% stanford research systems SRS-830 lock-in amplifier instrument control driver

classdef SR830 < handle	%generate new class for SRS830 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    properties
        ADDR	%gpib address
        CHAN	%DC output or measurement channel
        instr
        V
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = SR830(ADDR)
            %nothing
        end
        
        function setvoltage(obj, V, channel)
            if(nargin == 1) %only object is being passed, return an error
                error('You must pass a voltage');
            end
            
            if(~isnumeric(V))
                error('Voltage must be a number');
            end
            
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number');
                end
            else
                channel = 1;
            end
            
            if(channel < 1 || channel > 4)
                error('Channel number must be between 1 and 4');
            end
            
            fprintf(obj.instr, sprintf('AUX V %d, %f', channel, V));
        end
        
        function voltage = getvoltage(obj, channel)
            
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number');
                end
            else
                channel = 1;
            end
            
            if(channel < 1 || channel > 4)
                error('Channel number must be between 1 and 4');
            end
            
            
            fprintf(obj.instr, 'AUXV? %d', channel);
            voltage = fscanf(obj.instr, '%f');
            
        end
            
        
        function output = iden(obj)
            output = query(obj.instr, '*IDN?');
        end
    end
end
