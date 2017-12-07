% TENMA.m
%
% Tenma 72-2550 power supply driver file
% This file is a matlab object that represents the tenma. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device is not needed.
%
% Note: The tenma has an usual programming interface and doesn't use normal
% communication standards and thus has to be specified at connection time
% by calling opendevice with the driver flag as so:
% tma = opendevice(addr, 'serial', 'driver', 'TENMA')
%
% Properties are variables that are part of this pseudo-device and represent
% settings that effect how the device or matlab works
%
% Methods are functions used to access the abilities of the device
% for example setting a voltage or reading in a resistance value
% current methods (functions) are listed below:
%
% Methods:
% setoutputvoltage: sets the maximum DC offset voltage
% getoutputvoltage: returns the currently set maximum DC offset voltage
% setoutputcurrent: sets the maximum output current
% getoutputcurrent: returns the currently set maximum output current
% setoutputstatus: turns the output on or off
% getoutputstatus: returns the output status value
% getmeas: reads current voltage and current and returns them

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

classdef TENMA < voltagesource & multimeter	%generate new class for TENMA and
    % make it a subclass of voltagesource and multimeter
    
    %declare some basic properties (variables) for use later
    % n.b. UNFINISHED
    properties
        instr
    end
    
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = TENMA(instr)
            % object = TENMA(instrumentObject, noresetFlag)
            % Creation object, called when TENMA is created by opendevice
            % handles any instrument-specific setup required
            
            %a visa object is passed when creating the object, so make it
            %part of the object here
            %instr.Terminator = '';
            obj.instr = instr;
            obj.instr.Terminator = '';
            
            % this is REQUIRED to communicate with the tenma, otherwise
            % it wont reply
            
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
            % delete(TENMAObject)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setoutputvoltage(this, V, ~)
            % SETOUTPUTVOLTAGE(v)
            %
            % Sets the maximum output voltage
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'VSET1:%02.2f', V);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTVOLTAGE to %2.2f V', class(this), inputname(1), this.instr.Name, V));
                end
                
            end
        end
        
        
        
        function output = getoutputvoltage(this, ~)
            % voltage = GETOUTPUTVOLTAGE
            %
            % Returns the set maximum voltage, does not read actual voltage
            
            fprintf(this.instr, 'VSET1?');
            output = str2double(char(fread(this.instr, 5)));
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTVOLTAGE is %2.2f V', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputcurrent(this, I, ~)
            % SETOUTPUTCURRENT(I)
            %
            % Sets the maximum output current
            
            % if current is empty or doesn't exist then we want to return
            % an error
            if(nargin == 1 || ~exist('I', 'var') || isempty(I))
                error('No current provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the current
                if(~isnumeric(I))
                    error('Current must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'ISET1:%02.3f', I);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTCURRENT to %2.3f A', class(this), inputname(1), this.instr.Name, I));
                end
                
            end
        end
        
        
        
        function output = getoutputcurrent(this, ~)
            % current = GETOUTPUTCURRENT
            %
            % Returns the set maximum output current, does not measure or
            % return the actual current output
            
            fprintf(this.instr, 'ISET1?');
            output = char(fread(this.instr, 6));
            output = str2double(output(1:5));
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTCURRENT is %2.3f A', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function [voltage, current] = getmeas(this, ~)
            % voltage = GETMEAS
            % [voltage, current] = GETMEAS
            %
            % Reads and returns the real, measured values for voltage and
            % current
            fprintf(this.instr, 'VOUT1?');
            voltage = str2double(char(fread(this.instr, 5)));
            
            fprintf(this.instr, 'IOUT1?');
            current = str2double(char(fread(this.instr, 5)));
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETMEAS is V: %2.2f V\t I: %2.3f A', class(this), inputname(1), this.instr.Name, voltage, current));
            end
            
        end
        
        
        
        function output = getoutputstatus(this, ~)
            % status = GETOUTPUTSTATUS
            %
            % Returns the output status, 1 is on and 0 is off
            fprintf(this.instr, 'STATUS?');
            reply = dec2bin( fread(this.instr, 1), 8);
            
            output = str2double(reply(2));
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTSTATUS is %u', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputstatus(this, status, varargin)
            % SETOUTPUTSTATUS(status)
            %
            % Turns the output on or off, 1 is on, 0 is off
            if(nargin == 1 || ~exist('status', 'var') || isempty(status))
                error('No output status provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                
                % otherwise set the status
                if(~isnumeric(status))
                    error('Output status must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'OUT%u', status);
                
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
