% K2450.m
%
% Keithley Sourcemeter 2450 driver file
% This file is a matlab object that represents the 2450. It provides standard
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

classdef K2450 < voltagesource	%generate new class for K2450 and make it
    % a subclass of voltagesource
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = K2450(instr)
            % object = K2450(instrumentObject, noresetFlag)
            % Creation object, called when K2450 is created by opendevice
            % handles any instrument-specific setup required
            
            obj.instr = instr;
            
            % flush the input and output queue as sometimes previous
            % measurements that were not terminated properly can persist
            % in the buffers
            
            flushinput(instr); %software buffers
            flushoutput(instr);
            clrdevice(instr); %hardware buffers
            
            % n.b. a lot of these dont look needed and might harm
            % measurements, double check this
            fprintf(obj.instr, '*RST');
            fprintf(obj.instr, 'SOUR:FUNC VOLT');
            fprintf(obj.instr, 'SENS:FUNC "CURR"');
            fprintf(obj.instr, 'SOUR:VOLT:READ:BACK ON');
            fprintf(obj.instr, 'SOUR:VOLT 0');
            fprintf(obj.instr, 'OUTP ON');
            
            % read the settings file and set the verbose level
            obj.verbose = getsettings('verbose');
            obj.logging = getsettings('logging');
            
            logmessage(1, obj, sprintf('%s connected at %s', class(obj), obj.instr.Name));
            
        end
        
        
        function delete(this)
            % delete(K2450Object)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setconf(this, type, varargin)
            % SETCONF(type)
            %
            % Sets the configuration of the device, choose from 'dcvolt' or
            % 'dccurr'
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
                
            else
                switch type
                    case 'dcvolt'
                        fprintf(this.instr, 'SOUR:FUNC VOLT');
                        
                    case 'dccurr'
                        fprintf(this.instr, 'SOUR:FUNC CURR');
                        
                    otherwise
                        error('Unrecognised type%s', instrerror(this, inputname(1), dbstack));
                        
                end
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETCONF to %s', class(this), inputname(1), this.instr.Name, type));
                end
                
            end
            
        end
        
        
        
        function output = getconf(this, varargin)
            % type = GETCONF
            %
            % Returns currently set output type
            
            fprintf(this.instr, 'SOUR:FUNC?');
            output = fscanf(this.instr, '%s');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETCONF is %s', class(this), inputname(1), this.instr.Name, output));
            end
            
            
        end
        
        
        
        function setoutputvoltage(this, V, varargin)
            % SETOUTPUTVOLTAGE(v)
            %
            % Sets the output voltage
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'SOUR:VOLT %f', V);
                fprintf(this.instr, 'TRAC:TRIG');
                
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
            
            fprintf(this.instr, 'SOUR:VOLT?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTVOLTAGE is %2.3f', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function output = getmeas(this, varargin)
            % voltage = GETMEAS
            %
            % Returns the real output voltage
            fprintf(this.instr, 'READ?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETMEAS is %2.3f', class(this), inputname(1), this.instr.Name, output));
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
