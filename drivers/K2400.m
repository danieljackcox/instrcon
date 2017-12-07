% K2400.m
%
% Keithley Sourcemeter 2400 driver file
% This file is a matlab object that represents the 2400. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Properties are variables that are part of this pseudo-device and represent
% settings that effect how the device or matlab works
%
% Methods are functions used to access the abilities of the device
% for example setting a voltage or reading in a resistance value
% current methods (functions) are listed below:
%
% Methods:
% setconf: sets configuration type
% getconf: gets configuration
% setoutputvoltage: sets DC voltage or reads current set voltage
% getoutputvoltage: reads set DC voltage
% getmeas: depending on how the device is configured, reads voltage, current, resistance
% setoutputstatus: turns output on or off
% setoutputstatus: returns the output status

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

classdef K2400 < voltagesource	%generate new class for K2400 and make it a subclass of handle
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = K2400(instr)
            % object = K2400(instrumentObject, noresetFlag)
            % Creation object, called when K2400 is created by opendevice
            % handles any instrument-specific setup required
            
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
            
            % flush the input and output queue as sometimes previous
            % measurements that were not terminated properly can persist
            % in the buffers
            
            flushinput(instr); %software buffers
            flushoutput(instr);
            clrdevice(instr); %hardware buffers
            
            % read the settings file and set the verbose level
            obj.verbose = getsettings('verbose');
            obj.logging = getsettings('logging');
            
            logmessage(1, obj, sprintf('%s connected at %s', class(obj), obj.instr.Name));
        end
        
        
        function delete(this)
            % delete(K2400Object)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setconf(this, type, varargin)
            % SETCONF(type)
            %
            % Sets the measurement type, choose from 'dcvolt', 'dccurr',
            % 'res'
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('No arugments provided%s', instrerror(this, inputname(1), dbstack));
                
            else
                switch type
                    case 'dcvolt'
                        fprintf(this.instr, ':CONF:VOLT:DC');
                        
                    case 'dccurr'
                        fprintf(this.instr, ':CONF:CURR:DC');
                        
                    case 'res'
                        fprintf(this.instr, ':CONF:RES');
                        
                    otherwise
                        error('Unrecognised type%s', instrerror(this, inputname(1), dbstack));
                        
                end
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETCONF to %s', class(this), inputname(1), this.instr.Name, type));
                end
                
            end
            
        end
        
        
        
        function output = getconf(this, varargin)
            % config = GETCONF
            %
            % Returns current configuration as a string (not the same as
            % setconf)
            
            
            fprintf(this.instr, ':CONF?');
            output = fscanf(this.instr, '%s');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETCONF is %s', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputvoltage(this, V, varargin)
            % SETOUTPUTVOLTAGE(v)
            %
            % Sets the output voltage
            % Note that internal limits of the device may apply
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, ':SOUR:VOLT %f', V);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTVOLTAGE to %2.3f', class(this), inputname(1), this.instr.Name, V));
                end
                
            end
        end
        
        
        
        function output = getoutputvoltage(this, varargin)
            % voltage = GETOUTPUTVOLTAGE
            %
            % Returns the currently set output voltage, does not measure
            % actual voltage
            
            
            fprintf(this.instr, ':SOUR:VOLT?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTVOLTAGE is %2.3f', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function [voltage, current, resistance] = getmeas(this, varargin)
            % voltage = GETMEAS
            % [voltage, current, resistance] = GETMEAS
            %
            % Returns the output of the device
            fprintf(this.instr, ':READ?');
            
            tmp_output = scanstr(this.instr, ',', '%f');
            
            %any value returned which equals 9.91e37 is not a number so
            %lets redefine it here
            tmp_output(tmp_output == 9.91e37) = NaN;
            
            voltage = tmp_output(1);
            current = tmp_output(2);
            resistance = tmp_output(3);
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETMEAS is volt: %2.3f\t curr: %2.3f\t res: %6.1f', class(this), inputname(1), this.instr.Name, voltage, current, resistance));
            end
            
            
        end
        
        
        
        function output = getoutputstatus(this, varargin)
            % status = GETOUTPUTSTATUS
            %
            % Returns the value of the output, 1 is on, 0 is off
            
            fprintf(this.instr, 'OUTP1:STAT?');
            output = fscanf(this.instr, '%u');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTSTATUS is %u', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputstatus(this, status, varargin)
            % SETOUTPUTSTATUS(status)
            %
            % Turns output on or off, 1 is on, 0 is off
            
            % if status is empty or doesn't exist then return error
            if(nargin == 1 || ~exist('status', 'var') || isempty(status))
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(status))
                    error('Output status must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                if(status == 0)
                    fprintf(this.instr, 'OUTP1 OFF');
                elseif(status == 1)
                    fprintf(this.instr, 'OUTP1 ON');
                else
                    error('Output status must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS to %u', class(this), inputname(1), this.instr.Name, status));
                end
                
            end
            
        end
        
        
        
        function rst(this, varargin)
            % RST
            %
            % Sends SCPI *RST command
            fprintf(this.instr, '*RST');
        end
        
        
        
        function output = idn(this, varargin)
            % IDN
            %
            % Returns SCPI *IDN results
            fprintf(this.instr, 'IDN?');
            output = fscanf(this.instr, '%s');
        end
        
    end
end
