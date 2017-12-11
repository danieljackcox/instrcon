% AN9310A.m
%
% Agilent N9310A signal generator driver file
% This file is a matlab thisect that represents the N9310A. It provides standard
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

classdef AN9310A < freqgenerator	%generate new class for AN9310A and
    % make it a subclass of freqgenerator
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
        logging;
    end
    
    
    methods
        
        function obj = AN9310A(instr)
            % object = AN9310A(instrumentObject, noresetFlag)
            % Creation object, called when AN9310A is created by opendevice
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
            % delete(AN9310AObject)
            % Destruction object, will close the instrument and handle anything
            % needed before that
            
            fclose(this.instr);
            logmessage(1, this, sprintf('%s disconnected at %s', class(this), this.instr.Name));
        end
        
        
        
        function setfreq(this, freq, ~)
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
                
                fprintf(this.instr, ':FREQuency:CW %f kHz', freq/1000);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETFREQ to %6.0f Hz', class(this), inputname(1), this.instr.Name, freq));
                end
                
            end
            
        end
        
        
        
        function output = getfreq(this, ~)
            % frequency = GETFREQ
            %
            % Returns the set frequency
            
            fprintf(this.instr, ':FREQuency:CW?');
            output = fscanf(this.instr, '%s');
            
            %because this device returns a unit then we need to strip that
            %out
            output = strsplit(output);
            
            if(output{2} == 'GHz')
                output = output{1}*1e9;
            elseif(output{2} == 'MHz')
                output = output{1}*1e6;
            elseif(output{2} == 'kHz')
                output = output{1}*1e3;
            else
                error('Malformed output from device received%s', instrerror(this, inputname(1), dbstack));
            end
            
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETFREQ is %f Hz', class(this), inputname(1), this.instr.Name, output));
            end
        end
        
        
        
        function setexc(this, excitation, varargin)
            % SETEXC(excitation)
            % SETEXC(excitation, 'unit', excunits)
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
                    
                    if( sum(strcmpi({'dbm', 'dbmv', 'dbuv', 'mv', 'uv'}, varargin{unitidx+1})) ~= 1 )
                        error('Unit must be ''dbm'', ''dbmv'', ''dbuv'', ''mv'', ''uv''%s', instrerror(this, inputname(1), dbstack));
                    end
                    
                    %otherwise everything ok
                    unit = varargin{unitidx+1};
                end

                %set the excitation
                fprintf(this.instr, sprintf(':AMPLitude:CW %f %s', excitation, unit));
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETEXC to %2.1f %s', class(this), inputname(1), this.instr.Name, excitation, unit));
                end
                
            end
            
        end
        
        
        
        function output = getexc(this, ~)
            % excitation = GETEXC
            %
            % Returns excitation power in dBm
            
            fprintf(this.instr, ':AMPLitude:CW?');
            output = fscanf(this.instr, '%s');
            
            output = strsplit(output);
            output = output{1};
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETEXC is %f dBm', class(this), inputname(1), this.instr.Name, output));
            end
        end
        
        
        
        function output = getoutputstatus(this, ~)
            % status = GETOUTPUTSTATUS
            %
            % Returns the status of the RF output
            
            fprintf(this.instr, ':RFOutput:STATe?');
            output = fscanf(this.instr, '%u');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETOUTPUTSTATUS is %u', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setoutputstatus(this, status, ~)
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
                
                fprintf(this.instr, ':RFOutput:STATe %u', status);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETOUTPUTSTATUS to %u', class(this), inputname(1), this.instr.Name, status));
                end
                
            end
            
        end
    end
end
