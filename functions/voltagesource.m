%% voltagesource.m
%     Created 2017 Daniel Cox
%     Part of instrcon
%
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
%%
%
%
%
% this file contains high level functions used with voltage sources and
% defines the minimum functions a voltage source driver should expose
%
% minimum functions:
% getoutputvoltage
% setoutputvoltage
%
% high level functions
% RAMPVOLTAGE
%
% rampvoltage: safely ramps the DC output voltage of the generator
classdef voltagesource < handle
    
    properties (Abstract)
        instr;
    end
    
    methods
        % constructor object
        function obj = voltagesource

        end
        
    end
    
    methods (Abstract)
        
        getoutputvoltage(this)
        setoutputvoltage(this)
        getoutputstatus(this)
        setoutputstatus(this)
        
    end
    
    methods
        
        function rampvoltage(this, voltage, varargin)
            % RAMPVOLTAGE
            % RAMPVOLTAGE(this, voltage)
            % RAMPVOLTAGE(this, voltage, 'channel', ChannelValue, 'stepsize', StepSizeValue, 'steptime', StepTimeValue, 'imm')
            if( nargin == 0 )
                error('No arguments passed%s', instrerror(this, inputname(1), dbstack));
            end
            
            if( ~exist('this', 'var') || isempty(this) )
                error('A device object must be passed%s', instrerror(this, inputname(1), dbstack));
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
                    error('Step size should be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                %otherwise everything ok
                stepsize = varargin{stepsizeidx+1};
            end
            
            %if steptime isnt set then we fallback to default 10 ms
            if(~any(steptimeidx))
                steptime = 1e-3 ;
            else
                
                %if a steptime is not a number then throw an error
                if(~isnumeric(varargin{steptimeidx+1}))
                    error('Step time should be a number%s', instrerror(this, inputname(1), dbstack));
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
                    error('Channel should be a number%s', instrerror(this, inputname(1), dbstack));
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
            
            % this concerns devices like K2400 that have output control
            % is voltage source turned on?
            outputstatus = this.getoutputstatus;
            
            % if voltage source is off, set to zero and turn on
            if(outputstatus == 0)
                this.setoutputvoltage(0, 'channel', channel);
                this.setoutputstatus(1, 'channel', channel);
                logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS on channel %d ON', class(this), inputname(1), this.instr.Name, channel));
            end
            
            
            current_voltage = this.getoutputvoltage('channel', channel);
            
            if( current_voltage == voltage )
                %no nothing
            else
                if(imm == 1)
                    this.setoutputvoltage(voltage, 'channel', channel);
                else
                    rampvoltage = linspace(current_voltage, voltage, round(abs(diff([current_voltage voltage]))/stepsize)+1);
                    for i=1:length(rampvoltage)
                        this.setoutputvoltage(rampvoltage(i), 'channel', channel);
                        java.lang.Thread.sleep(1000*steptime);
                    end
                    logmessage(2, this, sprintf('%s ''%s'' at %s RAMPVOLTAGE on channel %d from %2.3f V to %2.3f V\n                            stepsize: %2.3f V\tsteptime: %2.3f s\timm: %d', class(this), inputname(1), this.instr.Name, channel, current_voltage, rampvoltage(end), stepsize, steptime, imm));
                end
            end
        end
    end
end
