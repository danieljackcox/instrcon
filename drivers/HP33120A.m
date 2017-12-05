% HP33120A.m
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
%
%------------------------------------------------------------------------------%
% HP/Agilent/keysight 33120A function generator driver file
% This file is a matlab thisect that represents the 33120A. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% setconf: configure the function generator to output the desired signal type
% getconf: returns the current configuration of the generator
% setoutputvoltage: sets the DC offset voltage
% getoutputvoltage: returns the currently set DC offset voltage
% freq: sets wave frequency for current configured type
% setexcitation: sets wave amplitude (RMS) for current configured type
% getexcitation: gets wave amplitude (RMS) for current configured type


%------------------------------------------------------------------------------%

classdef HP33120A < voltagesource & freqgenerator	%generate new class
    % for HP33120A and make it a subclass of voltagesource and freqgenerator
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
        verbose;
        logging;
    end
    
    
    methods
        
        function obj = HP33120A(instr)
            % object = HP33120A(instrumentObject)
            % Creation object, called when HP33120A is created by opendevice
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
            % delete(HP33120AObject)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end

        
        
        function setconf(this, type, varargin)
            % SETCONF(type)
            %
            % Sets the output function type, choose from 'sine', 'square',
            % 'triangle', 'ramp', 'noise', 'dc'
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('No config type provided, use ''getconf'' to read configuration%s', instrerror(this, inputname(1), dbstack));
                
            else
                switch type
                    
                    % if type is dcvolt then configure for DC voltage measurement
                    case 'sine'
                        fprintf(this.instr, 'FUNC:SHAP SIN');
                        
                        % if type is acvolt then configure for AC voltage measurement
                    case 'square'
                        fprintf(this.instr, 'FUNC:SHAP SQU');
                        
                        % if type is dccurr then configure for DC current measurement
                    case 'triangle'
                        fprintf(this.instr, 'FUNC:SHAP TRI');
                        
                        % if type is accurr then configure for AC voltage measurement
                    case 'ramp'
                        fprintf(this.instr, 'FUNC:SHAP RAMP');
                        
                        % if type is res then configure for resistance measurement
                    case 'noise'
                        fprintf(this.instr, 'FUNC:SHAP NOISE');
                        
                        % if type is 4res then configure for 4-probe resistance measurement
                    case 'dc'
                        fprintf(this.instr, 'FUNC:SHAP DC');
                        
                    otherwise
                        
                        error('Type ''%s'' not recognised, supported types are ''sine'', ''square'', ''triangle'', ''ramp'', ''noise'', ''dc''%s', type, instrerror(this, inputname(1), dbstack));
                end
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETCONF to %s', class(this), inputname(1), this.instr.Name, type));
                end
            end
        end

        
        
        function output = getconf(this, varargin)
            % configuration = GETCONF
            %
            % Returns the currently set output function (text)
            
            fprintf(this.instr, 'FUNC:SHAP?');
            output = fscanf(this.instr, '%s');
            
            if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s GETCONF IS %S', class(this), inputname(1), this.instr.Name, output));
                end
            
        end

        
        
        function setoutputvoltage(this, V, varargin)
            % SETOUTPUTVOLTAGE(V)
            % SETOUTPUTVOLTAGE(V, 'channel', channelnumber)
            %
            % Sets a DC voltage on the output
            % If called with no channel defaults to channel 1
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'VOLT:OFFS %f', V);
                
                if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTVOLTAGE to %2.3f V', class(this), inputname(1), this.instr.Name, V));
            end
                
            end
        end

        
        
        function output = getoutputvoltage(this, varargin)
            % voltage = GETOUTPUTVOLTAGE
            % voltage = GETOUTPUTVOLTAGE('channel', channelnumber)
            %
            % Returns the current set DC voltage, it does not measure real
            % voltage
            % If no channel is given defaults to channel 1
            
            fprintf(this.instr, 'VOLT:OFFS?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTVOLTAGE is %2.3f V', class(this), inputname(1), this.instr.Name, output));
            end
            
        end

        
        
        function setfreq(this, freq, varargin)
            % SETFREQ(f)
            % SETFREQ(f, 'channel', channelnumber)
            %
            % Sets the frequency of the output function
            % If called with no channel defaults to channel 1
            
            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(freq) )
                error('No frequency provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(freq))
                    error('Provided frequency must be a real number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'FREQ %f', freq);
                
                if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETFREQ to %6.3f Hz', class(this), inputname(1), this.instr.Name, freq));
            end
                
            end
            
        end

        
        
        function output = getfreq(this, varargin)
            % freq = GETFREQ
            % freq = GETFREQ('channel', channelnumber)
            %
            % Returns the currently set frequency of the output
            % If called with no channel then defaults to channel 1
            
            fprintf(this.instr, 'FREQ?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETFREQ is %6.3f Hz', class(this), inputname(1), this.instr.Name, output));
            end
            
            
        end

        
        
        function setexcitation(this, excitation, varargin)
            % SETEXCITATION(V)
            %
            % Sets the output excitation in V rms for ALL channels
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided%s', instrerror(this, inputname(1), dbstack));
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                %set the excitation
                fprintf(this.instr, 'VOLT %f', excitation);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETEXCITATION to %2.3f V', class(this), inputname(1), this.instr.Name, excitation));
                end
                
            end
            
        end

        
        
        function output = getexcitation(this, varargin)
            % excitation = GETEXCITATION
            %
            % Returns the AC excitation for current output function in V
            % rms, all channels the same
            
            fprintf(this.instr, 'VOLT?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETEXCITATION is %2.3f V', class(this), inputname(1), this.instr.Name, output));
            end
        end
        
        
        
        function output = getoutputstatus(this, varargin)
            % outputstatus = GETOUTPUTSTATUS
            %
            % Returns if DC sources are energised
            % Not an option on this instrument so returns 1 always
            output = 1;
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTSTATUS is %d', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputstatus(this, status, varargin)
            % SETOUTPUTSTATUS
            %
            % Not an option on this instrument so does nothing
            % this is meant to do nothing!
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS to 1', class(this), inputname(1), this.instr.Name));
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
