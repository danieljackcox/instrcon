% HP8656B.m
%
% HP8656B signal generator driver file
% This file is a matlab thisect that represents the 8656B. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Note: The 8656B is OLD and doesn't have an identity command, that means
% the opendevice function cannot automatically find it, you should call
% opendevice with the driver flag as so:
% sg = opendevice(addr, 'gpib', 'driver', 'HP8656B')
%
% Properties are variables that are part of this pseudo-device and represent
% settings that effect how the device or matlab works
%
% Methods are functions used to access the abilities of the device
% for example setting a voltage or reading in a resistance value
% current methods (functions) are listed below:
%
% Methods:
% freq: sets wave frequency for current configured type
% setexc: sets wave amplitude (RMS) for current configured type
% getexc: not supported - returns NaN
% setfreq: sets frequency
% getfreq: not supported - returns NaN
% setoutputstatus: switches output on or off
% getoutputstatus: not supported - returns 1

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

classdef HP8656B < freqgenerator	%generate new class for HP8656B and
    % make it a subclass of freqgenerator
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    
    
    methods
        
        function obj = HP8656B(instr)
            % object = HP8656B(instrumentObject, noresetFlag)
            % Creation object, called when HP8656B is created by opendevice
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
            % delete(HP8656BObject)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setfreq(this, freq, varargin)
            % SETFREQ(frequency)
            %
            % Sets the excitation frequency
            
            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(freq) )
                error('No frequency provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(freq))
                    error('Provided frequency must be a real number%s', instrerror(this, inputname(1), dbstack));
                end

                fprintf(this.instr, 'FR %8.0u HZ', freq);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETFREQ to %6.0f Hz', class(this), inputname(1), this.instr.Name, freq));
                end
                
            end
            
        end
        
        
        
        function output = getfreq(this, varargin)
            % frequency = GETFREQ
            %
            % Returns NaN on this device
            output = NaN;
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETFREQ is NaN (not supported)', class(this), inputname(1), this.instr.Name));
            end
        end
        
        
        
        function setexc(this, excitation, varargin)
            % SETEXC(excitation)
            % SETEXC(excitation, 'unit', excunit)
            %
            % Sets output excitation
            % Units can be 'dBm', 'dBmV', 'dBuV', 'mV', 'uV' (case
            % insensitive)
            % If no units are given then default is dbm
            
            
            % if empty or nonexistent then return error
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided%s', instrerror(this, inputname(1), dbstack));
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                % look to see if unit has been set
                unitidx = find(strcmpi('unit', varargin));
                
                %if unit isnt set then we fallback to default 'dbm'
                if(~any(unitidx))
                    unit = 'dbm' ;
                else
                    
                    %if a channel is not a number then throw an error
                    if(~ischar(varargin{unitidx+1}))
                        error('Unit needs to be a string input%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                    %otherwise everything ok
                    unit = varargin{unitidx+1};
                end
                
                % convert user input (dbm, etc.) to something the device
                % understands
                
                %use if statements instead of switch to make it case
                %insensitive
                
                if( strcmpi(unit, 'dbm') )
                    unit_fprintf = 'DM';
                elseif( strcmpi(unit, 'dbmv') )
                    unit_fprintf = 'DB MV';
                elseif( strcmpi(unit, 'dbuv') )
                    unit_fprintf = 'DB UV';
                elseif( strcmpi(unit, 'mv') )
                    unit_fprintf = 'MV';
                elseif( strcmpi(unit, 'uv') )
                    unit_fprintf = 'UV';
                else
                    error('Unit must be ''dbm'', ''dbmv'', ''dbuv'', ''mv'', ''uv''%s', instrerror(this, inputname(1), dbstack));
                end
                
                %set the excitation
                fprintf(this.instr, sprintf('AP %2.1f %s R3', excitation, unit_fprintf));
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETEXC to %2.1f %s', class(this), inputname(1), this.instr.Name, excitation, unit));
                end
                
            end
            
        end
        
        
        
        function output = getexc(this, varargin)
            % excitation = GETEXC
            %
            % Not supported on this device, returns NaN
            output = NaN;
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETEXC is NaN (not supported)', class(this), inputname(1), this.instr.Name));
            end
        end
        
        
        
        function output = getoutputstatus(this, varargin)
            % status = GETOUTPUTSTATUS
            %
            % Not supported on this device, returns 1
            
            output = 1;
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTSTATUS is 1', class(this), inputname(1), this.instr.Name, freq));
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
                    error('Output status must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                if(status == 0)
                    fprintf(this.instr, 'R2');
                    
                    if( length( dbstack ) < 2  )
                        logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS to 0', class(this), inputname(1), this.instr.Name));
                    end
                    
                elseif(status == 1)
                    fprintf(this.instr, 'R3');
                    
                    if( length( dbstack ) < 2  )
                        logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS to 1', class(this), inputname(1), this.instr.Name));
                    end
                    
                end
            end
            
        end
    end
end
