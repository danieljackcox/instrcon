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
%
%
%
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
        
        function rampvoltage(obj, voltage, varargin)
            % RAMPVOLTAGE
            % RAMPVOLTAGE(obj, voltage)
            % RAMPVOLTAGE(obj, voltage, 'channel', ChannelValue, 'stepsize', StepSizeValue, 'steptime', StepTimeValue, 'imm')
            if( nargin == 0 )
                error('No arguments passed');
            end
            
            if( ~exist('obj', 'var') || isempty(obj) )
                error('A device object must be passed');
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
            
            stepsizeidx = find(strcmpi('stepsize', varargin));
            steptimeidx = find(strcmpi('steptime', varargin));
            immidx = find(strcmpi('imm', varargin));
            channelidx = find(strcmpi('channel', varargin));
            
            %if stepsize isnt set then we fallback to default 50 mV
            if(~any(stepsizeidx))
                stepsize = 50e-3 ;
            else
    
                %if a stepsize is not a number then throw an error
                if(~isnumeric(varargin{stepsizeidx+1}))
                    error('Step size should be a number');
                end
    
                %otherwise everything ok
                stepsize = varargin{stepsizeidx+1};
            end
            
            %if steptime isnt set then we fallback to default 10 ms
            if(~any(steptimeidx))
                stepsize = 10e-3 ;
            else
    
                %if a steptime is not a number then throw an error
                if(~isnumeric(varargin{steptimeidx+1}))
                    error('Step time should be a number');
                end
    
                %otherwise everything ok
                steptime = varargin{steptimeidx+1};
            end
            
             %if channel isnt set then we fallback to default 1
            if(~any(channelidx))
                channel = 1 ;
            else
    
                %if a channel is not a number then throw an error
                if(~isnumeric(varargin{channelidx+1}))
                    error('Channel should be a number');
                end
    
                %otherwise everything ok
                channel = varargin{channelidx+1};
            end
            
            %if someone sets 'imm' then set the flag here
            if(any(immidx))
                imm = 1;
            else
                imm = 0;
            end
            
            %likewise if step time or size is zero then set imm
            if(stepsize == 0 || steptime == 0)
                imm = 1;
            end

            current_voltage = obj.getoutputvoltage(channel);
            
            if( current_voltage == voltage )
                %no nothing
            else
                if(imm == 1)
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
