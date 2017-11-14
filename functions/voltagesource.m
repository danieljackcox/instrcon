%voltagesource.m

% this file contains high level functions used with voltage sources and
% defines the minimum functions a voltage source driver should expose

% minimum functions:
% getoutputvoltage
% setoutputvoltage

% high level functions
% RAMPVOLTAGE

% rampvoltage: safely ramps the DC output voltage of the generator
classdef voltagesource < handle
    
    properties
        verb = 0; % verbosity, off by default
    end
    
    methods
        % constructor object
        function obj = voltagesource

        end
        
        
    end
    
    methods (Abstract)
       
        getoutputvoltage(this)
        setoutputvoltage(this)
       
        

        
    end
    
    methods
        
        
        
        function rampvoltage(obj, voltage, channel, imm, stepsize, speed)
            % RAMPVOLTAGE
            % RAMPVOLTAGE(obj, voltage, channel, imm, stepsize, speed)
            run('rampvoltage.m');
        end
        
        
    end
    
end
