%voltagesource.m
%     Created 2017 Daniel Cox
%     Part of instrcon

%     instrcon is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.





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
            if( nargin == 0 )
                error('No arguments passed');
            end
            
            if( ~exist('obj', 'var') || isempty(obj) )
                error('A device object must be passed');
            end
            
            if( ~exist('imm', 'var') || isempty(imm) )
                imm = 0;
            end
            
            if( ~ismember(imm, 0:1) )
                error('imm must be 0 or 1');
            end
            
            if( ~exist('channel', 'var') || isempty(channel) )
                channel = 1;
            end
            
            if( ~isnumeric(channel) )
                error('Channel must be a number');
            end
            
            %    if( ~exists(range_change) || isempty(range_change) )
            %        if( ~ismember(range_change, 0:1) )
            %            error('range_change must be 0 or 1');
            %        end
            %        range_change = 0;
            %    end
            
            if( ~exist('stepsize', 'var') || isempty(stepsize) )
                stepsize = 50e-3;
            end
            
            if( ~isnumeric(stepsize) )
                error('Step size must be a number');
            end
            
            if( ~exist('speed', 'var') || isempty(speed) )
                speed = 10e-3;
            end
            
            if( ~isnumeric(speed) )
                error('Speed must be a number');
            end
            
            
            current_voltage = obj.getoutputvoltage(channel);
            
            
            if( current_voltage == voltage )
                %no nothing
            else
                
                if( imm == 1)
                    obj.setoutputvoltage(voltage, channel);
                else
                    rampvoltage = linspace(current_voltage, voltage, round(abs(diff([current_voltage voltage]))/stepsize)+1);
                    for i=1:length(rampvoltage)
                        obj.setoutputvoltage(rampvoltage(i), channel);
                        java.lang.Thread.sleep(1000*speed);
                    end
                    
                end
            end
        end
        
        
    end
    
end
