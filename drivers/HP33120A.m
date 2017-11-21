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
        V
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = HP33120A(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setconf: sets the output function type.                           %
        % Choose from sine, square, triangle, ramp, noise, dc               %
        % arbitrary waveforms not implemented
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setconf(this, type, varargin)
            
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
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getconf: reads the output function type.                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getconf(this, varargin)
            
            fprintf(this.instr, 'CONF?');
            output = fscanf(this.instr, '%s');
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputvoltage: sets a DC voltage                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setoutputvoltage(this, V, varargin)
            
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
                
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputvoltage: reads a DC voltage                              %
        % IMPORTANT: getvoltage returns the *set* voltage value, it does    %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getoutputvoltage(this, varargin)
            
            
            fprintf(this.instr, 'VOLT:OFFS?');
            output = fscanf(this.instr, '%f');
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setfreq: sets internal frequency              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setfreq(this, freq, varargin)
            
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
                
            end
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getfreq: reads internal frequency              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getfreq(this, varargin)
            
            
            fprintf(this.instr, 'FREQ?');
            output = fscanf(this.instr, '%f');
            
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setxcitation: sets the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setexcitation(this, excitation, varargin)
            
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
                
            end
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getexcitation: returns the AC output sine wave voltage (in RMS)      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getexcitation(this, varargin)
            
            
            fprintf(this.instr, 'VOLT?');
            output = fscanf(this.instr, '%f');
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputstatus: always returns 1                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getoutputstatus(this, varargin)
            
            output = 1;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputstatus: function does nothing but is required %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setoutputstatus(this, status, varargin)
            % this is meant to do nothing!
        end
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % rst: sends GPIB *RST command (i.e. resets the device)             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function rst(this, varargin)
            fprintf(this.instr, '*RST');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % idn: gets GPIB identity                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = idn(this, varargin)
            fprintf(this.instr, 'IDN?');
            output = fscanf(this.instr, '%s');
        end
        
    end
end
