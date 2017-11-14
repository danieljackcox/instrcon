%virthardware.m

% this file contains higher-level instrument control functions like safe
% voltage ramping, it's not something you should directly interact with as
% such, rather you call the virthardware functions through the connected
% device, i.e. to sweep voltage on a voltage generator gen, call
% gen.rampvoltage(voltage). The internal workings of rampvoltage use the
% methods exposed as part of the driver file for the device

% rampvoltage: safely ramps the DC output voltage of the generator
classdef virthardware < handle
    
    properties
        verb = 0; % verbosity, off by default
    end
    
    methods
        % constructor object
        function obj = virthardware

        end
        
    end
    
    methods
        
        
        
        function rampvoltage(obj, voltage, channel, imm, stepsize, speed)
            run('rampvoltage.m');
        end
        
        
    end
    
end
