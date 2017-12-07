% A33522A.m
%
% HP/Agilent/keysight 33522A function generator driver file
% This file is a matlab thisect that represents the 33522A. It provides standard
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
% setconf: configure the function generator to output the desired signal type
% getconf: returns the current configuration of the generator
% setoutputvoltage: sets the DC offset voltage
% getoutputvoltage: returns the currently set DC offset voltage
% freq: sets wave frequency for current configured type
% setexc: sets wave amplitude (RMS) for current configured type
% getexc: gets wave amplitude (RMS) for current configured type

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

classdef A33522A < voltagesource	%generate new class for A33522A and
    % make it a subclass of voltagesource
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
        logging;
    end
    
    
    
    methods
        
        function obj = A33522A(instr)
            % object = A33522A(instrumentObject)
            % Creation object, called when A33522A is created by opendevice
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
            % delete(A33522AObject)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setconf(this, type, varargin)
            % SETCONF(type)
            %
            % Sets the device to output the function type provided
            % Types are 'sine', 'square', 'triangle', 'ramp', 'noise', 'dc'
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('no configuration provided%s', instrerror(this, inputname(1), dbstack));
                
            else
                switch type
                    
                    % if type is dcvolt then configure for DC voltage measurement
                    case 'sine'
                        fprintf(this.instr, 'FUNC SIN');
                        
                        % if type is acvolt then configure for AC voltage measurement
                    case 'square'
                        fprintf(this.instr, 'FUNC SQU');
                        
                        % if type is dccurr then configure for DC current measurement
                    case 'triangle'
                        fprintf(this.instr, 'FUNC TRI');
                        
                        % if type is accurr then configure for AC voltage measurement
                    case 'ramp'
                        fprintf(this.instr, 'FUNC RAMP');
                        
                        % if type is res then configure for resistance measurement
                    case 'noise'
                        fprintf(this.instr, 'FUNC NOISE');
                        
                        % if type is 4res then configure for 4-probe resistance measurement
                    case 'dc'
                        fprintf(this.instr, 'FUNC DC');
                        
                    otherwise
                        error('Unrecognised type%s', instrerror(this, inputname(1), dbstack));
                end
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETCONF to %s', class(this), inputname(1), this.instr.Name, type));
                end
            end
        end
        
        
        
        function output = getconf(this, varargin)
            % configuration = GETCONF
            %
            % Returns the current output function
            % Types are 'sin', 'squ', 'tri', 'ramp', 'noise', 'dc'
            
            
            fprintf(this.instr, 'CONF?');
            output = fscanf(this.instr, '%s');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETCONF is %s', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputvoltage(this, V, varargin)
            % SETOUTPUTVOLTAGE(V)
            % SETOUTPUTVOLTAGE(V, 'channel', channelnumber)
            %
            % Sets a DC voltage on the output
            % If called with no channel defaults to channel 1
            
            % look to see if channel has been set
            channelidx = find(strcmpi('channel', varargin));
            
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
            
            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'SOUR%d:VOLT:OFFS %f', channel, V);
                
            end
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTVOLTAGE on channel %d to %2.3f V', class(this), inputname(1), this.instr.Name, channel, V));
            end
        end
        
        
        
        function output = getoutputvoltage(this, varargin)
            % voltage = GETOUTPUTVOLTAGE
            % voltage = GETOUTPUTVOLTAGE('channel', channelnumber)
            %
            % Returns the current set DC voltage, it does not measure real
            % voltage
            % If no channel is given defaults to channel 1
            
            % look to see if channel has been set
            channelidx = find(strcmpi('channel', varargin));
            
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
            
            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            fprintf(this.instr, 'SOUR%d:VOLT:OFFS?', channel);
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTVOLTAGE on channel %d is %2.3f V', class(this), inputname(1), this.instr.Name, channel, output));
            end
            
        end
        
        
        
        function setfreq(this, freq, varargin)
            % SETFREQ(f)
            % SETFREQ(f, 'channel', channelnumber)
            %
            % Sets the frequency of the output function
            % If called with no channel defaults to channel 1
            
            % look to see if channel has been set
            channelidx = find(strcmpi('channel', varargin));
            
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
            
            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(freq) )
                error('No frequency provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(freq))
                    error('Provided frequency must be a real number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'SOUR%d:FREQ %f', channel, freq);
                
            end
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETFREQ on channel %d to %6.3f Hz', class(this), inputname(1), this.instr.Name, channel, freq));
            end
            
        end
        
        
        
        function output = getfreq(this, varargin)
            % freq = GETFREQ
            % freq = GETFREQ('channel', channelnumber)
            %
            % Returns the currently set frequency of the output
            % If called with no channel then defaults to channel 1
            
            % look to see if channel has been set
            channelidx = find(strcmpi('channel', varargin));
            
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
            
            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            
            fprintf(this.instr, 'SOUR%d:FREQ?', channel);
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETFREQ on channel %d is %6.3f Hz', class(this), inputname(1), this.instr.Name, channel, output));
            end
            
            
        end
        
        
        
        function setexc(this, excitation, varargin)
            % SETEXC(V)
            %
            % Sets the output excitation in V rms for ALL channels
            
            % for some reason this device doesn't have per channel
            % amplitude control
            
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
        
        
        
        function output = getexc(this, varargin)
            % excitation = GETEXC
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
