% K2400.m
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
% Keithley Sourcemeter 2400 driver file
% This file is a matlab object that represents the 2400. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% configure: set or read dc voltage
% setoutputvoltage: sets DC voltage or reads current set voltage
% getmeas: depending on how the device is configured, reads voltage, current, resistance


%------------------------------------------------------------------------------%

classdef K2400 < voltagesource	%generate new class for K2400 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        verbose;
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = K2400(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
            
            % read the settings file and set the verbose level
            obj.verbose = getsettings('verbose');
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setconf: sets the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setconf(this, type, varargin)
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('No arugments provided%s', instrerror(this, inputname(1), dbstack));
                
            else
                switch type
                    case 'dcvolt'
                        fprintf(this.instr, ':CONF:VOLT:DC');
                        
                    case 'dccurr'
                        fprintf(this.instr, ':CONF:CURR:DC');
                        
                    case 'res'
                        fprintf(this.instr, ':CONF:RES');
                        
                    otherwise
                        error('Unrecognised type%s', instrerror(this, inputname(1), dbstack));
                        
                end
                
            end
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getconf: reads the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getconf(this, varargin)
            
            
            fprintf(this.instr, ':CONF?');
            output = fscanf(this.instr, '%s');
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputvoltage: sets a DC voltage                            %                                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setoutputvoltage(this, V, varargin)
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, ':SOUR:VOLT %f', V);
                
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputvoltage: reads a DC voltage                            %
        % IMPORTANT: setoutputvoltage can return the *set* voltage value, it does %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getoutputvoltage(this, varargin)
            
            
            fprintf(this.instr, ':SOUR:VOLT?');
            output = fscanf(this.instr, '%f');
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getmeas: sends a read command and then reads the output of    %
        % the device, in this case V, I and R                              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [voltage, current, resistance] = getmeas(this, varargin)
            fprintf(this.instr, ':READ?');
            
            tmp_output = scanstr(this.instr, ',', '%f');
            
            %any value returned which equals 9.91e37 is not a number so
            %lets redefine it here
            tmp_output(tmp_output == 9.91e37) = NaN;
            
            voltage = tmp_output(1);
            current = tmp_output(2);
            resistance = tmp_output(3);
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputstatus: returns output status of device (output energised %
        % or not                                                             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getoutputstatus(this, varargin)
            
            fprintf(this.instr, 'OUTP1:STAT?');
            output = fscanf(this.instr, '%u');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputstatus: turns the output on or off            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setoutputstatus(this, status, varargin)
            % if status is empty or doesn't exist then return error
            if(nargin == 1 || ~exist('status', 'var') || isempty(status))
                error('No arguments provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(status))
                    error('Output status must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                if(status == 0)
                    fprintf(this.instr, 'OUTP1 OFF');
                elseif(status == 1)
                    fprintf(this.instr, 'OUTP1 ON');
                else
                    error('Output status must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
            end
            
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
            fprintf(this.instr, '*IDN?');
            output = fscanf(this.instr, '%s');
        end
        
    end
end
