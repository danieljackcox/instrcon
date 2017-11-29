% KS3351xB.m
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
%------------------------------------------------------------------------------%
% HKeysight 33510B/33511B function generator driver file
% This file is a matlab object that represents the 33510B/33511B.
% It provides standard methods that interface with the
% device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% To use in measurement scripts first call the OPENDEVICE function
% e.g. lia = OPENDEVICE(5, 'gpib')
% This will create an SR830 object and assign it to lia variable
% You can then call functions like SETOUTPUTVOLTAGE
% lia.SETOUTPUTVOLTAGE(5)
% or
% SETOUTPUTVOLTAGE(lia, 5)
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
% setfreq: sets wave frequency for current configured type
% getfreq: returns wave frequency for current configured type
% setexcitation: sets wave amplitude (RMS) for current configured type
% getexcitation: gets wave amplitude (RMS) for current configured type
% getoutputstatus: returns if outputs are energised or not
% setoutputstatus: Turns on or off the outputs



classdef KS3351xB < voltagesource	%generate new class for KS3351xB and
    % make it a subclass of voltagesource
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = KS3351xB(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
            
            % read the settings file and set the verbose level
            obj.verbose = getsettings('verbose');
        end
        
        
        
        function setconf(this, type, varargin)
            % SETCONF(type)
            % SETCONF(type, 'channel', channelnumber)
            %
            % Configures the output function of the device, choices for type are
            % 'sine', 'square', 'triangle', 'ramp', 'noise', 'dc'
            % arbitary output not implemented
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
            % if no arguments provided then return an error
            if( nargin == 1 )
                error('no configuration provided%s', instrerror(this, inputname(1), dbstack));
                
            else
                
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
                
                % make sure that the channel is a number between 1 and 2
                if( ~ismember(channel, 1:2) )
                    error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
                end
                
                switch type
                    
                    % if type is dcvolt then configure for DC voltage measurement
                    case 'sine'
                        fprintf(this.instr, 'SOUR%d:FUNC SIN', channel);
                        
                        % if type is acvolt then configure for AC voltage measurement
                    case 'square'
                        fprintf(this.instr, 'SOUR%d:FUNC SQU', channel);
                        
                        % if type is dccurr then configure for DC current measurement
                    case 'triangle'
                        fprintf(this.instr, 'SOUR%d:FUNC TRI', channel);
                        
                        % if type is accurr then configure for AC voltage measurement
                    case 'ramp'
                        fprintf(this.instr, 'SOUR%d:FUNC RAMP', channel);
                        
                        % if type is res then configure for resistance measurement
                    case 'noise'
                        fprintf(this.instr, 'SOUR%d:FUNC NOISE', channel);
                        
                        % if type is 4res then configure for 4-probe resistance measurement
                    case 'dc'
                        fprintf(this.instr, 'SOUR%d:FUNC DC', channel);
                        
                    otherwise
                        error('Unrecognised type%s', instrerror(this, inputname(1), dbstack));
                end
            end
        end
        
        
        
        function output = getconf(this, varargin)
            % GETCONF()
            % GETCONF('channel', channelnumber)
            %
            % Returns the current function output type as a string
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            fprintf(this.instr, 'SOUR%d:FUNC?', channel);
            output = fscanf(this.instr, '%s');
            
        end
        
        
        
        function setoutputvoltage(this, V, varargin)
            % SETOUTPUTVOLTAGE(voltage)
            % SETOUTPUTVOLTAGE(voltage, 'channel', channelnumber)
            %
            % Sets the DC output voltage
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
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
        end
        
        
        
        function output = getoutputvoltage(this, varargin)
            % GETOUTPUTVOLTAGE()
            % GETOUTPUTVOLTAGE('channel', channelnumber)
            %
            % Returns the set DC output voltage
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            fprintf(this.instr, 'SOUR%d:VOLT:OFFS?', channel);
            output = fscanf(this.instr, '%f');
            
        end
        
        
        
        function setfreq(this, freq, varargin)
            % SETFREQ(frequency)
            % SETFREQ(frequency, 'channel', channelnumber)
            %
            % Sets the output frequency when using compatible function type
            % Might error if not using compatible type
            % n.b. check if this errors
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
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
            
        end
        
        
        
        function output = getfreq(this, varargin)
            % GETFREQ()
            % GETFREQ('channel', channelnumber)
            %
            % Returns set output frequency
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            
            fprintf(this.instr, 'SOUR%d:FREQ?', channel);
            output = fscanf(this.instr, '%f');
            
            
        end
        
        
        
        function setexcitation(this, excitation, varargin)
            % SETEXCITATION(voltage)
            % SETEXCITATION(voltage, 'channel', channelnumber)
            %
            % Sets the RMS output excitation voltage
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided%s', instrerror(this, inputname(1), dbstack));
            else
                
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
                
                % make sure that the channel is a number between 1 and 2
                if( ~ismember(channel, 1:2) )
                    error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
                end
                
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('Excitation must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                %set the excitation
                fprintf(this.instr, sprintf('SOUR%d:VOLT %f', channel, excitation));
                
            end
            
        end
        
        
        
        function output = getexcitation(this, varargin)
            % GETEXCITATION()
            % GETEXCITATION('channel', channelnumber)
            %
            % Returns the set RMS output excitation voltage
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            fprintf(this.instr, 'SOUR%d:VOLT?', channel);
            output = fscanf(this.instr, '%f');
            
            
        end
        
        
        
        function output = getoutputstatus(this, varargin)
            % GETOUTPUTSTATUS()
            % GETOUTPUTSTATUS('channel', channelnumber)
            %
            % Returns the output status (if the front connector is energised
            % or not)
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            
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
            
            % make sure that the channel is a number between 1 and 2
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            
            fprintf(this.instr, 'OUTP%d?', channel);
            output = fscanf(this.instr, '%s');
            
        end
        
        
        
        function setoutputstatus(this, status, varargin)
            % SETOUTPUTSTATUS(status)
            % SETOUTPUTSTATUS(status, 'channel', channelnumber)
            %
            % Sets the output status (if the front connector is energised
            % or not)
            % NOTE: On the single channel device (33511B) the channel option is
            % ignored
            if( nargin == 1 || isempty(status) )
                error('No status provided%s', instrerror(this, inputname(1), dbstack));
            else
                
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
                
                % make sure that the channel is a number between 1 and 2
                if( ~ismember(channel, 1:2) )
                    error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
                end
                
                % check if passed value is a number
                if( ~ismember(status, 1:2) )
                    error('Status must be 0(off) or 1(on)%s', instrerror(this, inputname(1), dbstack));
                end
                
                %set the status
                fprintf(this.instr, sprintf('OUTP%d %d', channel, status));
                
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
