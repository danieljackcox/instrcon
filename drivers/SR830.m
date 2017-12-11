% SR830.m
%
% Stanford Research Systems SR830 Lock-in Amplifier driver file
% This file is a matlab object that represents the SR830. It provides standard
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
% setoutputvoltage: sets dc voltage on AUX output
% getoutputvoltage: reads current set dc voltage on AUX output
% getinputvoltage: reads voltage from aux input
% setfreqref: sets internal or external reference
% getfreqref: reads current set reference type
% setphase: sets phase shift
% getphase: reads phase shift
% setfreq: set AC excitation frequency
% getfreq: reads AC excitation frequency
% setreftrig: sets whether to use sine or TTL reference trigger
% getreftrig: reads reference trigger type
% setharmonic: set measurement harmonic
% getharmonic: read measurement harmonic
% setexc: set AC excitation voltage
% getexc: read current set AC excitation voltage
% setinputconfig: set the input configuration (A, A-B, I, etc.)
% getinputconfig: read the input configuration
% setshieldgrounding: set shield grounding configurationflushinput(instr); %software buffers
% flushoutput(instr);
% clrdevice(instr);
% getshieldgrounding: read shield grounding configuration
% setnotchfilter: set the notch filter configuration
% getnotchfilter: read the notch filter configuration
% setsensitivity: set the sensitivity
% getsensitivity: read the sensitivity
% setreserve: set reserve
% getreserve: read reserve
% settc: set time constant
% gettc: read time constant
% setlpfilterslope: set low pass filter slope
% getlpfilterslope: read low pass filter slope
% setsyncfilter: set synchronous filter status
% getsyncfilter: read synchronous filter status
% getmeas: reads X, Y, R, phase components from the input
% setoutputstatus: turns output on or off (does nothing here)
% getoutputstatus: returns output status (always on)

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
%

%generate new class for SR830 and make it a subclass
% of voltagesource and freqgenerator
classdef SR830 < voltagesource & freqgenerator
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        phaseoffset;
        inputground;
        harmonic;
        inputconfig;
        notchfilter;
        reserve;
        tc;
        filterslope;
        syncfilter;
        inputcoupling;
        verbose;
        logging;
    end
    
    
    methods
        
        function obj = SR830(instr, noreset)
            % object = SR830(instrumentObject, noresetFlag)
            % Creation object, called when SR830 is created by opendevice
            % handles any instrument-specific setup required
            
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
            
            if(exist('noreset', 'var'))
                if(~isnumeric(noreset))
                    error('Noreset must be an integer\%s', instrerror(this, inputname(1), dbstack));
                end
            else
                noreset = 0;
            end
            
            if(noreset == 1)
                %do absolutely nothing
            else
                %fprintf(obj.instr, '*RST');
            end
            
            % flush the input and output queue as sometimes previous
            % measurements that were not terminated properly can persist
            % in the buffers
            
                        flushinput(instr); %software buffers
                        flushoutput(instr);
                        clrdevice(instr); %hardware buffers
            %
            %
            %
            %             obj.getsettings;
            
            % read the settings file and set the verbose level
            obj.verbose = getsettings('verbose');
            obj.logging = getsettings('logging');
            
            logmessage(1, obj, sprintf('%s connected at %s', class(obj), obj.instr.Name));
            
        end
        
        
        
        function delete(this)
            % delete(SR830Object)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setoutputvoltage(this, V, varargin)
            % SETOUTPUTVOLTAGE(voltage)
            % SETOUTPUTVOLTAGE(voltage, 'channel', channelnumber)
            %
            % Sets a DC voltage on the auxillary output
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
            if( ~ismember(channel, 1:4) )
                error('Channel number must be between 1 and 4%s', instrerror(this, inputname(1), dbstack));
            end
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage passed%s', instrerror(this, inputname(1), dbstack));
                
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, sprintf('AUX V %d, %f', channel, V));
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTVOLTAGE on channel %d to %2.3f V', class(this), inputname(1), this.instr.Name, channel, V));
                end
            end
        end
        
        
        
        function output = getoutputvoltage(this, varargin)
            % voltage = GETOUTPUTVOLTAGE
            % voltage = GETOUTPUTVOLTAGE('channel', channelnumber)
            %
            % Returns the user-set voltage on auxillary outputs
            %
            % If called with no channel defaults to channel 1
            % NOTE: It does not read the actual voltage
            % it just reads what it has been set to
            
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
            if( ~ismember(channel, 1:4) )
                error('Channel number must be between 1 and 4%s', instrerror(this, inputname(1), dbstack));
            end
            
            %if we got this far then everything should be fine
            fprintf(this.instr, 'AUXV? %d', channel);
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTVOLTAGE on channel %d is %2.3f V', class(this), inputname(1), this.instr.Name, channel, output));
            end
        end
        
        
        
        function output = getinputvoltage(this, varargin)
            % voltage = GETINPUTVOLTAGE
            % voltage = GETINPUTVOLTAGE('channel', channelnumber)
            %
            % Returns the voltage measured on auxillary inputs
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
            if( ~ismember(channel, 1:4) )
                error('Channel number must be between 1 and 4%s', instrerror(this, inputname(1), dbstack));
            end
            
            % read the voltage and output
            fprintf(this.instr, 'OAUX? %d', channel);
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETINPUTVOLTAGE on channel %d is %2.3f V', class(this), inputname(1), this.instr.Name, channel, output));
            end
            
        end
        
        
        
        function setfreq(this, freq, varargin)
            % SETFREQ(frequency)
            %
            % Sets the excitation frequency
            
            if( ~isnumeric(freq))
                error('Provided frequency must be a real number%s', instrerror(this, inputname(1), dbstack));
            end
            
            % passes all error checking, then execute
            fprintf(this.instr, 'FREQ %f', freq);
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETFREQ to %6.3f Hz', class(this), inputname(1), this.instr.Name, freq));
            end
            
        end
        
        
        
        function output = getfreq(this, varargin)
            % frequency = GETFREQ
            %
            % Returns the AC excitation frequency set
            % Does not actually measure frequency, just returns set value
            
            fprintf(this.instr, 'FREQ?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETFREQ is %6.3f Hz', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function output = getoutputstatus(varargin)
            % outputstatus = GETOUTPUTSTATUS
            %
            % Returns if DC sources are energised
            % Not an option on this instrument so returns 1 always
            
            output = 1;
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTSTATUS is %d', class(this), inputname(1), this.instr.Name, output));
            end
        end
        
        
        
        function setoutputstatus(varargin)
            % SETOUTPUTSTATUS
            %
            % Not an option on this instrument so does nothing
            
            % this is meant to do nothing!
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS to 1', class(this), inputname(1), this.instr.Name));
            end
        end
        
        
        
        function setfreqref(this, ref, varargin)
            % SETFREQREF(reference)
            % SETFREQREF('int')
            % SETFREQREF('ext')
            %
            % Sets instrument to use internal or external frequency reference
            % Accepts numeric arguments (0 or 1)
            % OR text arguments ('int' or 'ext')
            
            if( ~isnumeric(ref))
                ref_text = {'int','ext'};
                
                ref = find(strcmpi(ref, ref_text)) - 1;
            end
            
            % passes all error checking, then execute
            fprintf(this.instr, 'FMOD %d', ref);
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s SETFREQREF to %d', class(this), inputname(1), this.instr.Name, ref));
            end
            
        end
        
        
        
        function [output, humanreadable] = getfreqref(this, varargin)
            % freqref = GETFREQREF
            % [freqref, human_readable_version] = GETFREQREF
            %
            % Returns status of frequency reference, 0 or 1
            % Also returns a second variable as text, 'int' or 'ext'
            
            fprintf(this.instr, 'FMOD?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            fr_text = {'int','ext'};
            humanreadable = fr_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETFREQREF is %s', class(this), inputname(1), this.instr.Name, humanreadable));
            end
            
        end
        
        
        
        function setphase(this, phase, varargin)
            % SETPHASE(phase)
            %
            % Sets the phase shift in the device, phase in degrees
            
            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(phase) )
                error('No phase provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(phase))
                    error('Provided phase must be a real number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'PHAS %f', phase);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETPHASE to %3.3f', class(this), inputname(1), this.instr.Name, phase));
                end
                
            end
            
        end
        
        
        
        function output = getphase(this, varargin)
            % phase = GETPHASE
            %
            % Returns phase shift in degrees
            
            
            fprintf(this.instr, 'PHAS?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETPHASE is %3.3f', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setreftrig(this, trigtype, varargin)
            % SETREFTRIG(trigtype)
            % SETREFTRIG('sine')
            %
            % Sets the reference frequency trigger type
            % to sine, TTL rising edge or TTL falling edge
            % Arguments are numeric (0, 1, 2)
            % or text ('sine', 'rising', 'falling')
            
            %if empty or nonexistent then return an error
            if( nargin == 1 || isempty(trigtype) )
                error('No Reference Type provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise we set the value
                
                % check that it is a real number
                if( ~isnumeric(trigtype))
                    rt_text = {'sine', 'rising', 'falling'};
                    
                    trigtype = find(strcmpi(trigtype, rt_text)) - 1;
                else
                    % and check that the number is 0, 1, or 2
                    if( ~ismember(trigtype, 0:2) )
                        error('Input must be 0, 1, or 2%s', instrerror(this, inputname(1), dbstack));
                    end
                end
                
                fprintf(this.instr, 'RSLP %d', trigtype);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETREFTRIG to %d', class(this), inputname(1), this.instr.Name, trigtype));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = getreftrig(this, varargin)
            % reftrig = GETREFTRIG
            % [reftrig, human_readable_version] = GETREFTRIG
            %
            % Returns status of reference trigger, 0, 1 or 2
            % Also returns a second variable as text
            % 'sine', 'rising' or 'falling'
            
            
            fprintf(this.instr, 'RSLP?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            rt_text = {'sine', 'rising', 'falling'};
            humanreadable = rt_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETREFTRIG is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setharmonic(this, harmonic, varargin)
            % SETHARMONIC(harmonic)
            %
            % Sets the frequency harmonic to measure
            % harmonic should be an integer, 1 or higher
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(harmonic) )
                error('No harmonic provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise check if passed value is a number then set it
                if( ~isnumeric(harmonic))
                    error('Harmonic must be an integer larger than 0%s', instrerror(this, inputname(1), dbstack));
                end
                
                
                fprintf(this.instr, 'HARM %d', harmonic);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETHARMONIC to %d', class(this), inputname(1), this.instr.Name, harmonic));
                end
                
            end
            
        end
        
        
        
        function output = getharmonic(this, varargin)
            % harmonic = GETHARMONIC
            %
            % Returns frequency harmonic used
            % 'sine', 'rising' or 'falling'
            
            fprintf(this.instr, 'HARM?');
            output = fscanf(this.instr, '%d');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETHARMONIC is %d', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setexc(this, excitation, varargin)
            % SETEXC(voltage)
            %
            % Sets the rms output voltage of the AC excitation
            % NOTE: the SR830 output voltage has a minimum step size of 2 mV
            % If you use a voltage between this step size it is rounded down
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided%s', instrerror(this, inputname(1), dbstack));
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                %set the excitation
                fprintf(this.instr, 'SLVL %f', excitation);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETEXCITATION to %1.3f V', class(this), inputname(1), this.instr.Name, excitation));
                end
                
            end
            
        end
        
        
        
        function output = getexc(this, varargin)
            % voltage = GETEXC
            %
            % Returns the AC excitation voltage in rms volts
            
            
            fprintf(this.instr, 'SLVL?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETEXCITATION is %1.3f V', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setinputconfig(this, inputconfig, varargin)
            % SETINPUTCONFIG(config)
            % SETINPUTCONFIG('A-B')
            %
            % Sets the input configuration
            % Choice between A, A-B, I (1MOhm), I (100 MOhm)
            % Input is numeric (0, 1, 2, 3) or text
            % 'A', 'A-B', 'I (10MOhm)','I (100MOhm)'
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(inputconfig) )
                error('No input config provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if passed value is a number, and then check if it is
                % in the accepted range
                if( ~isnumeric(inputconfig))
                    ic_text = {'A','A-B','I (10MOhm)','I (100MOhm)'};
                    
                    inputconfig = find(strcmpi(inputconfig, ic_text)) - 1;
                    
                else
                    
                    if( ~ismember(inputconfig, 0:3) )
                        error('Input must be 0, 1, 2, or 3%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                end
                
                % set the value
                fprintf(this.instr, 'ISRC %d', inputconfig);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETINPUTCONFIG to %d', class(this), inputname(1), this.instr.Name, inputconfig));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = getinputconfig(this, varargin)
            % config = GETINPUTCONFIG
            % [config, human_readable] = GETINPUTCONFIG
            %
            % Returns input configuration
            % Also returns second variable with human readable text
            
            fprintf(this.instr, 'ISRC?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'A','A-B','I (10MOhm)','I (100MOhm)'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETINPUTCONFIG is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setshieldgrounding(this, shieldground, varargin)
            % SETSHIELDGROUNDING(config)
            % SETSHIELDGROUNDING('floating')
            % SETSHIELDGROUNDING('grounded')
            %
            % Sets grounding configuration on input, numeric or text input
            % Numeric values allowed are 0 or 1
            % text values allowed are 'floating' or 'grounded'
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(shieldground) )
                error('No ground shield configuration provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(shieldground))
                    shield_text = {'floating', 'grounded'};
                    
                    shieldground = find(strcmpi(shieldground, shield_text)) - 1;
                else
                    
                    if( ~ismember(shieldground, [0 1]) )
                        error('Input must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                end
                
                % set the value
                fprintf(this.instr, 'IGND %d', shieldground);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETSHIELDGROUNDING to %d', class(this), inputname(1), this.instr.Name, shieldground));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = getshieldgrounding(this, varargin)
            % config = GETSHIELDGROUNDING
            % [config, human_readable] = GETSHIELDGROUNDING
            %
            % Return shield grounding configuration
            % Returns second variable as human readable text
            % 'floating' or 'grounded'
            
            fprintf(this.instr, 'IGND?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'floating','grounded'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETSHIELDGROUNDING is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setnotchfilter(this, notchfilter, varargin)
            % SETNOTCHFILTER(notchfilter)
            % SETNOTCHFILTER('1x')
            %
            % Sets the notch filter
            % Input is numeric (0, 1, 2, 3) or text
            % 'none', '1x', '2x', '1x & 2x'
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(notchfilter) )
                error('no notch filter provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(notchfilter))
                    notch_text = {'none', '1x', '2x', '1x & 2x'};
                    
                    
                    notchfilter = find(strcmpi(notchfilter, notch_text)) - 1;
                else
                    
                    if( ~ismember(notchfilter , 0:3) )
                        error('Input must be between 0 and 3%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                end
                
                % set the value
                fprintf(this.instr, 'ILIN %d', notchfilter);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETNOTCHFILTER to %d', class(this), inputname(1), this.instr.Name, notchfilter));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = getnotchfilter(this, varargin)
            % notchfilter = GETNOTCHFILTER
            % [notchfilter, human_readable] = GETNOTCHFILTER
            %
            % Returns notch filter status
            % Also returns second variable as human readable text
            
            fprintf(this.instr, 'ILIN?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'none','1x','2x','1x & 2x'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETNOTCHFILTER is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setsensitivity(this, sensitivity, varargin)
            % SETSENSITIVITY(sensitivity)
            % SETSENSITIVITY('2 uV')
            %
            % Set the measurement sensitivity
            % Accepts numeric argument (0-26)
            % also accepts text input, e.g. '5 nV', '1 mV'
            %
            % The input
            % is an integer that corresponds to a sensitivity listed below
            % 0       2 nV/fA             13          50 uV/pA
            % 1       5 nV/fA             14          100 uV/pA
            % 2       10 nV/fA            15          200 uV/pA
            % 3       20 nV/fA            16          500 uV/pA
            % 4       50 nV/fA            17          1 mV/nA
            % 5       100 nV/fA           18          2 mV/nA
            % 6       200 nV/fA           19          5 mV/nA
            % 7       500 nV/fA           20          10 mV/nA
            % 8       1 uV/pA             21          20 mV/nA
            % 9       2 uV/pA             22          50 mV/nA
            % 10      5 uV/pA             23          100 mV/nA
            % 11      10 uV/pA            24          200 mV/nA
            %                             26          1 V/uA
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(sensitivity) )
                error('no sensitivity provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check range is correct
                if( ~isnumeric(sensitivity))
                    sens_text = {'2 nV', '5 nV', '10 nV', '20 nV', ...
                        '50 nV', '100 nV', '200 nV', '500 nV', '1 uV', ...
                        '2 uV', '5 uV', '10 uV', '20 uV', '50 uV', '100 uV', ...
                        '200 uV', '500 uV', '1 mV', '2 mV', '5 mV', '10 mV', ...
                        '20 mV', '50 mV', '100 mV', '200 mV', '500 mV', '1 V'};
                    
                    
                    sensitivity = find(strcmpi(sensitivity, sens_text)) - 1;
                else
                    
                    if( ~ismember(sensitivity, 0:26) )
                        error('Input must be an integer between 0 and 26%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                end
                
                % set the value
                fprintf(this.instr, 'SENS %d', sensitivity);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETSENSITIVITY is %d', class(this), inputname(1), this.instr.Name, sensitivity));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = getsensitivity(this, varargin)
            % sensitivity = GETSENSITIVITY
            % [sensitivity, human_readable] = GETSENSITIVITY
            %
            % Returns current sensitivity
            % Second variable is human readable text
            %
            % The output
            % is an integer that corresponds to a sensitivity listed below
            % 0       2 nV/fA             13          50 uV/pA
            % 1       5 nV/fA             14          100 uV/pA
            % 2       10 nV/fA            15          200 uV/pA
            % 3       20 nV/fA            16          500 uV/pA
            % 4       50 nV/fA            17          1 mV/nA
            % 5       100 nV/fA           18          2 mV/nA
            % 6       200 nV/fA           19          5 mV/nA
            % 7       500 nV/fA           20          10 mV/nA
            % 8       1 uV/pA             21          20 mV/nA
            % 9       2 uV/pA             22          50 mV/nA
            % 10      5 uV/pA             23          100 mV/nA
            % 11      10 uV/pA            24          200 mV/nA
            %                             26          1 V/uA
            
            
            fprintf(this.instr, 'SENS?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'2 nV', '5 nV', '10 nV', '20 nV', ...
                '50 nV', '100 nV', '200 nV', '500 nV', '1 uV', ...
                '2 uV', '5 uV', '10 uV', '20 uV', '50 uV', '100 uV', ...
                '200 uV', '500 uV', '1 mV', '2 mV', '5 mV', '10 mV', ...
                '20 mV', '50 mV', '100 mV', '200 mV', '500 mV', '1 V'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETSENSITIVITY is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setreserve(this, reserve, varargin)
            % SETRESERVE(reserve)
            % SETRESERVE('high')
            %
            % Sets the reserve, input is numeric (0,1,2) or text
            % 'high', 'normal', 'low noise'
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(reserve) )
                error('no reserve provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(reserve) )
                    rs_text = {'high', 'normal', 'low noise'};
                    
                    reserve = find(strcmpi(reserve, rs_text)) - 1;
                else
                    
                    if( ~ismember(reserve , 0:2) )
                        error('Input must be between 0 and 2%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                end
                
                % set the value
                fprintf(this.instr, 'RMOD %d', reserve);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETRESERVE is %d', class(this), inputname(1), this.instr.Name, reserve));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = getreserve(this, varargin)
            % reserve = GETRESERVE
            % [reserve, human_readable] = GETRESERVE
            %
            % Returns reserve status, 0, 1, 2
            % Second variable is human readable text
            
            fprintf(this.instr, 'RMOD?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'high','normal','low noise'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETRESERVE is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function settc(this, tc, varargin)
            % SETTC(tc)
            % SETTC('300 ms')
            %
            % Sets the time constant in seconds, inputs are numeric or text
            % Number range should be between 0-30
            % Text input should be in seconds, i.e. '1 s', '30 ms', etc.
            % see SR830 manual for full details
            % NOTE: Measurement settling time is typically 5 times the tc time
            %
            % The input
            % is an integer that corresponds to a time constant listed below
            %
            % 0       10 ??s            10          1 s
            % 1       30 ??s            11          3 s
            % 2       100 ??s           12          10 s
            % 3       300 ??s           13          30 s
            % 4       1 ms              14          100 s
            % 5       3 ms              15          300 s
            % 6       10 ms             16          1 ks
            % 7       30 ms             17          3 ks
            % 8       100 ms            18          10 ks
            % 9       300 ms            19          30 ks
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(tc) )
                error('no tc provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check range is correct
                if( ~isnumeric(tc))
                    tc_text = {'10 uS', '30 uS', '100 uS', '300 uS', ...
                        '1 ms', '3 ms', '10 ms', '30 ms', '100 ms', ...
                        '300 ms', '1 s', '10 s', '30 s', '100 s', '300 s', ...
                        '1 ks', '3 ks', '10 ks', '30 ks'};
                    
                    tc = find(strcmpi(tc, tc_text)) - 1;
                else
                    
                    if( ~ismember(tc, 0:19) )
                        error('Input must be an integer between 0 and 19%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                end
                
                % set the value
                fprintf(this.instr, 'OFLT %d', tc);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETTC is %d', class(this), inputname(1), this.instr.Name, tc));
                end
                
            end
            
        end
        
        
        
        function [output, humanreadable] = gettc(this, varargin)
            % tc = GETTC
            % [tc, human_readable] = GETTC
            %
            % Returns current time constant
            % Output is numeric (see SR830 manual)
            % Second variable returns human readable text
            %
            % The output
            % is an integer that corresponds to a time constant listed below
            %
            % 0       10 ??s            10          1 s
            % 1       30 ??s            11          3 s
            % 2       100 ??s           12          10 s
            % 3       300 ??s           13          30 s
            % 4       1 ms              14          100 s
            % 5       3 ms              15          300 s
            % 6       10 ms             16          1 ks
            % 7       30 ms             17          3 ks
            % 8       100 ms            18          10 ks
            % 9       300 ms            19          30 ks
            
            
            fprintf(this.instr, 'OFLT?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'10 uS', '30 uS', '100 uS', '300 uS', ...
                '1 ms', '3 ms', '10 ms', '30 ms', '100 ms', ...
                '300 ms', '1 s', '10 s', '30 s', '100 s', '300 s', ...
                '1 ks', '3 ks', '10 ks', '30 ks'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETTC is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setlpfilterslope(this, lpfilterslope, varargin)
            % SETLPFILTERSLOPE(slope)
            %
            % Sets the low-pass filter slope in dB/oct
            % Input is numeric, either numbers from SR830 manual (0,1,2,3)
            % or the actual dB/oct numbers (6, 12, 18, 24)
            % no text input supported
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(lpfilterslope) )
                error('no filter slope provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(lpfilterslope) )
                    error('Filter slope must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                if( ~ismember(lpfilterslope , [0:3, 6, 12, 18, 24]) )
                    error('Input must be between 0 and 3 OR 6, 12, 18, 24%s', instrerror(this, inputname(1), dbstack));
                end
                
                if( ismember(lpfilterslope , [6, 12, 18, 24]) )
                    lpfilterslope = (lpfilterslope/6) - 1;
                end
                
                % set the value
                fprintf(this.instr, 'OFSL %d', lpfilterslope);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETLPFILTERSLOPE to %d', class(this), inputname(1), this.instr.Name, lpfilterslope));
                end
                
            end
            
        end
        
        
        
        function output = getlpfilterslope(this, varargin)
            % slope = GETLPFILTERSLOPE
            % [slope, human_readable] = GETLPFILTERSLOPE
            %
            % Returns setting of low-pass filter slope
            % Numeric values are from SR830 manual (0,1,2,3)
            % Second variable returns human readable text
            
            
            fprintf(this.instr, 'OFSL?');
            output = fscanf(this.instr, '%d');
            
            %make a human-readable list of settings
            inputconfig_text = {'6 dB/oct', '12 dB/oct', '18 dB/oct', ...
                '24 dB/oct'};
            humanreadable = inputconfig_text{output+1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETLPFILTERSLOPE is %s (%d)', class(this), inputname(1), this.instr.Name, humanreadable, output));
            end
            
        end
        
        
        
        function setsyncfilter(this, syncfilter, varargin)
            % SETSYNCFILTER(filter)
            %
            % turns the synchronous filter on or off
            % filter should be 0 or 1
            % only operates when frequency is below 200 Hz
            % recommended to keep on
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(syncfilter) )
                error('no sync filter provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(syncfilter) )
                    error('Sync filter status must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                if( ~ismember(syncfilter , 0:1) )
                    error('Input must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                % set the value
                fprintf(this.instr, 'SYNC %d', syncfilter);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETSYNCFILTER to %d', class(this), inputname(1), this.instr.Name, syncfilter));
                end
                
            end
            
        end
        
        
        
        function output = getsyncfilter(this, varargin)
            % filter = GETSYNCFILTER
            %
            % Returns status of sync filter
            % 0 or 1 (off or on)
            
            fprintf(this.instr, 'SYNC?');
            output = fscanf(this.instr, '%d');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETSYNCFILTER is %d', class(this), inputname(1), this.instr.Name, output));
            end
            
            
        end
        
        
        
        function setinputcoupling(this, inputcoupling, varargin)
            % SETINPUTCOUPLING(coupling)
            %
            % Sets the input coupling
            % AC(0) or DC(1)
            
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(inputcoupling) )
                error('no input coupling provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(inputcoupling) )
                    error('Input coupling must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                if( ~ismember(inputcoupling , 0:1) )
                    error('Input must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                % set the value
                fprintf(this.instr, 'ICPL %d', inputcoupling);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETINPUTCOUPLING to %d', class(this), inputname(1), this.instr.Name, inputcoupling));
                end
                
            end
            
        end
        
        
        
        function output = getinputcoupling(this, varargin)
            % coupling = GETINPUTCOUPLING
            %
            % Returns status of input coupling
            % AC(o) or DC(1)
            
            
            fprintf(this.instr, 'ICPL?');
            output = fscanf(this.instr, '%d');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETINPUTCOUPLING is %d', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function [r, x, y, phase] = getmeas(this, varargin)
            % [r, x, y, phase] = GETMEAS
            %
            % Triggers a measurement, returns r, x, y, and phase components
            % x and y components are measured simultaneously as are r and phase
            % this means that there is a small delay between measuring x,y and
            % r, phase making it possible they will yield slightly different
            % results, this should not be a problem except at very short time
            % constants.
            
            % dont need to do anything except ask the device for the
            % values
            fprintf(this.instr, 'SNAP? 1,2,3,4');
            tmp_output = scanstr(this.instr, ',', '%f');
            
            % assign tmp_output to proper variables just for readability
            X       = tmp_output(1);
            Y       = tmp_output(2);
            R       = tmp_output(3);
            phase   = tmp_output(4);
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETMEAS is r: %e\tx: %e\ty: %e\tp: %e', class(this), inputname(1), this.instr.Name, r, x, y, phase));
            end
            
        end
        
        
        
        function getsettings(this, varargin)
            % GETSETTINGS
            % sets the current device settings and sets them as properties
            % most likely will be depreciated soon
            
            %get the settings
            phaseoffset = this.getphase;
            inputground = this.getshieldgrounding;
            harmonic = this.getharmonic;
            inputconfiguration = this.getinputconfig;
            inputcoupling = this.getinputcoupling;
            notchfilter = this.getnotchfilter;
            reserve = this.getreserve;
            tc = this.gettc;
            filterslope = this.getlpfilterslope;
            syncfilter = this.getsyncfilter;
            
            %make a human-readable list of settings
            inputconfig_text = {'A','A-B','I (10MOhm)','I (100MOhm)'};
            inputground_text = {'float','ground'};
            inputcoupling_text = {'AC','DC'};
            notchfilter_text = {'none','50Hz','100Hz','50+100Hz'};
            reserve_text = {'high','normal','low noise'};
            timeconstant_text = {'10us','30us','100us','300us','1ms','3ms','10ms','30ms','100ms','300ms','1s','3s','10s','30s','100s','300s','1ks','3ks','10ks','30ks'};
            filterslope_text = {'6dB/oct','12dB/oct','18dB/oct','24dB/oct'};
            syncfilter_text = {'off','on'};
            
            %commit the changes
            
            this.phaseoffset = phaseoffset;
            this.inputground = inputground_text{inputground + 1};
            this.harmonic = harmonic;
            this.inputconfig = inputconfig_text{inputconfiguration+1};
            this.notchfilter = notchfilter_text{notchfilter+1};
            this.reserve = reserve_text{reserve+1};
            this.tc = timeconstant_text{tc+1};
            this.filterslope = filterslope_text{filterslope+1};
            this.syncfilter = syncfilter_text{syncfilter+1};
            this.inputcoupling = inputcoupling_text{inputcoupling+1};
            
            
            
            
            
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
