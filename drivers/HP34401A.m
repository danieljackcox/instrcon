% HP34401A.m
%
% HP/Agilent 34401A multimeter driver file
% This file is a matlab object that represents the 34401A. It provides standard
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
% configure: sets the device in the measurement mode requested
% trigger: triggers the device to measure, seperated from getmeas functionality
% because this can take some time
% getmeas: reads the configured output after a trigger event
% detband: changes the detection band filter (3, 20, 200 Hz)
% integrationtime: changes the integration time for measurement (unfinished)

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

classdef HP34401A < multimeter	%generate new class for HP34401A and make it a subclass of common
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = HP34401A(instr)
            % object = HP34401A(instrumentObject, noresetFlag)
            % Creation object, called when HP34401A is created by opendevice
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
            % delete(HP34401AObject)
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
                error('No arugments provided%s', instrerror(this, inputname(1), dbstack));
                
            else
                switch type
                    
                    %n.b. check if these still work...
                    
                    % if type is dcvolt then configure for DC voltage measurement
                    case 'dcvolt'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:VOLT:DC', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:VOLT:DC');
                        end
                        
                        % if type is acvolt then configure for AC voltage measurement
                    case 'acvolt'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:VOLT:AC', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:VOLT:AC');
                        end
                        % if type is dccurr then configure for DC current measurement
                    case 'dccurr'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:CURR:DC', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:CURR:DC');
                        end
                        % if type is accurr then configure for AC voltage measurement
                    case 'accurr'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:CURR:AC', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:CURR:AC');
                        end
                        % if type is res then configure for resistance measurement
                    case 'res'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:RES', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:RES');
                        end
                        % if type is 4res then configure for 4-probe resistance measurement
                    case '4res'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:FRES', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:FRES');
                        end
                        % if type is freq then configure for frequency measurement
                    case 'freq'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:FREQ', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:FREQ');
                        end
                        % if type is per then configure for period measurement
                    case 'per'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:PER', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:PER');
                        end
                        % if type is cont then configure for continuity measurement
                    case 'cont'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:CONT', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:CONT');
                        end
                        % if type is diode then configure for diode measurement
                    case 'diode'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:DIOD', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:DIOD');
                        end
                        % if type isnt matched then throw an error
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
            % Returns the currently set function measurement type as a string
            
            
            fprintf(this.instr, 'CONF?');
            output = fscanf(this.instr, '%s');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETCONF is %s', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function trigger(this, varargin)
            % TRIGGER
            %
            % Sends a trigger command to the dvm, is used to initiate a
            % measurement
            fprintf(this.instr, 'INIT;FETC?');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s TRIGGER', class(this), inputname(1), this.instr.Name));
            end
        end
        
        
        
        function output = getmeas(this, varargin)
            % output = GETMEAS
            %
            % Returns the output of a measurement
            % TRIGGER must be used first
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETMEAS is %f', class(this), inputname(1), this.instr.Name, output));
            end
        end
        
        
        
        function setdetband(this, detband, varargin)
            % SETDETBAND(detection_bandwidth)
            %
            % Sets the detection bandwidth used in measurement, has
            % implications on noise of signal
            % Choose from 3, 20, 200 Hz
            
            if( ~exist('detband', 'var') || isempty(detband) )
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                if( ~ismember(detband, [3, 20, 200]) )
                    error('Detection band can only be 3 Hz, 20 Hz, or 200 Hz%s', instrerror(this, inputname(1), dbstack));
                end
                fprintf(this.instr, 'DET:BAND %u', detband);
                
                if( length( dbstack ) < 2  )
                    logmessage(2, this, sprintf('%s ''%s'' at %s SETDETBAND to %u Hz', class(this), inputname(1), this.instr.Name, detband));
                end
            end
            
        end
        
        
        
        function output = getdetband(this, varargin)
            % detection_band = GETDETBAND
            %
            % Returns the currently set detection bandwidth in Hz
            
            
            fprintf(this.instr, 'DET:BAND?');
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETDETBAND is %u', class(this), inputname(1), this.instr.Name, output));
            end
            
        end
        
        
        
        function setintegrationtime(this, time, varargin)
            % SETINTEGRATIONTIME(time)
            %
            % Sets the integration time for the measurement
            % Input is either number of power line cycles (NPLC)
            % (numeric; 0.02, 0.2, 1, 10, 100)
            % or string ('fast4', 'slow4', 'fast5', 'slow5', 'fast6', 'slow6')
            
            %in order to set NPLC properly we need to know the current
            %measurement function
            fprintf(this.instr, 'FUNC?');
            
            %function is returned in quotes so strip those away
            functiontype = strsplit(fscanf(this.instr, '%s'), '"');
            functiontype = functiontype{2};
            
            
            if( ~exist('time', 'var') || isempty(time) )
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                % n.b. update how this function works to use current
                % practise, try to get rid of the switch
                if(isnumeric(time))
                    fprintf(this.instr, '%s:NPLC %f', functiontype, time);
                else
                    switch time
                        case 'fast4'
                            fprintf(this.instr, '%s:NPLC 0.02', functiontype);
                        case 'slow4'
                            fprintf(this.instr, '%s:NPLC 0.2', functiontype);
                        case 'fast5'
                            fprintf(this.instr, '%s:NPLC 1', functiontype);
                        case 'slow5'
                            fprintf(this.instr, '%s:NPLC 10', functiontype);
                        case 'fast6'
                            fprintf(this.instr, '%s:NPLC 10', functiontype);
                        case 'slow6'
                            fprintf(this.instr, '%s:NPLC 100', functiontype);
                        otherwise
                            error('Unrecognised NPLC amount%s', instrerror(this, inputname(1), dbstack));
                    end
                end
            end
            
        end
        
        
        
        function output = getintegrationtime(this, varargin)
            % int_time = GETINTEGRATIONTIME
            %
            % Returns the set integration time in number of power line
            % cycles (NPLC)
            
            %in order to set NPLC properly we need to know the current
            %measurement function
            fprintf(this.instr, 'FUNC?');
            
            %function is returned in quotes so strip those away
            functiontype = strsplit(fscanf(this.instr, '%s'), '"');
            functiontype = functiontype{2};
            
            
            fprintf(this.instr, '%s:NPLC?', functiontype);
            output = fscanf(this.instr, '%f');
            
            if( length( dbstack ) < 2  )
                logmessage(2, this, sprintf('%s ''%s'' at %s GETINTEGRATIONTIME is %f', class(this), inputname(1), this.instr.Name, output));
            end
        end
    end
end
