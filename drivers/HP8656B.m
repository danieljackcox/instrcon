% HP8656B.m
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
% Methods:
% freq: sets wave frequency for current configured type
% setexcitation: sets wave amplitude (RMS) for current configured type
% getexcitation: gets wave amplitude (RMS) for current configured type


%------------------------------------------------------------------------------%

classdef HP8656B < freqgenerator	%generate new class for HP8656B and
    % make it a subclass of freqgenerator
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = HP8656B(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
            
            % read the settings file and set the verbose level
            obj.verbose = getsettings('verbose');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setfreq: sets frequency of output             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setfreq(this, freq, ~)
            
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
                
            end
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getfreq: not possible on this device, just return NaN %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getfreq(this, ~)
            output = NaN;
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setexcitation: sets the AC output sine wave voltage (in dBm)         %
        % also turns on RF automatically                                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setexcitation(this, excitation, ~)
            
            % if empty or nonexistent then return error
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided%s', instrerror(this, inputname(1), dbstack));
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                %set the excitation
                fprintf(this.instr, 'AP %2.1f DM R3', excitation);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getexcitation: not possible on this device, just return NaN          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getexcitation(this, ~)
            output = NaN;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputstatus: doesn't work on this device, return 1               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getoutputstatus(this, ~)
            
            output = 1;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputstatus: turns output on or off  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setoutputstatus(this, status, ~)
            
            if(nargin == 1 || ~exist('status', 'var') || isempty(status))
                error('No output status provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the status
                if(~isnumeric(status))
                    error('Output status must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                if(status == 0)
                    fprintf(this.instr, 'R2');
                elseif(status == 1)
                    fprintf(this.instr, 'R3');
                end
            end
            
        end
    end
