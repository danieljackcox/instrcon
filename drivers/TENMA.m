% TENMA.m
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
% Tenma 72-2550 power supply driver file
% This file is a matlab object that represents the tenma. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device is not needed.
%
% Note, the tenma programming is poorly designed in the device and can generate
% long delays
%
% Methods:
% setoutputvoltage: sets the DC offset voltage
% getoutputvoltage: returns the currently set DC offset voltage
%------------------------------------------------------------------------------%

classdef TENMA < voltagesource & multimeter	%generate new class for TENMA and
    % make it a subclass of voltagesource and multimeter
    
    
    %declare some basic properties (variables) for use later
    % n.b. UNFINISHED
    properties
        instr
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = TENMA(instr)
            %a visa object is passed when creating the object, so make it
            %part of the object here
            %instr.Terminator = '';
            obj.instr = instr;
            obj.instr.Terminator = '';
            
            % this is REQUIRED to communicate with the tenma, otherwise
            % it wont reply
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputvoltage: sets a DC voltage                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setoutputvoltage(this, V, ~)
            
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'VSET1:%02.2f', V);
                
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputvoltage: reads a DC voltage                              %
        % IMPORTANT: getvoltage returns the *set* voltage value, it does    %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getoutputvoltage(this, ~)
            
            fprintf(this.instr, 'VSET1?');
            output = str2double(char(fread(this.instr, 5)));
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputcurrent: sets a DC current                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function setoutputcurrent(this, I, ~)
            
            % if current is empty or doesn't exist then we want to return
            % an error
            if(nargin == 1 || ~exist('I', 'var') || isempty(I))
                error('No current provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                % otherwise set the current
                if(~isnumeric(I))
                    error('Current must be a number%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'ISET1:%02.3f', I);
                
            end
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputcurrent: reads a DC current                              %
        % IMPORTANT: getoutputcurrent returns the *set* current value       %
        % it does not measure any current                                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getoutputcurrent(this, ~)
            
            fprintf(this.instr, 'ISET1?');
            output = char(fread(this.instr, 6));
            output = str2double(output(1:5));
                        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getmeas: reads the actual measured values for voltage and current%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [voltage, current] = getmeas(this, ~)
            fprintf(this.instr, 'VOUT1?');
            voltage = str2double(char(fread(this.instr, 5)));
            
            fprintf(this.instr, 'IOUT1?');
            current = str2double(char(fread(this.instr, 5)));
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputstatus: return if output is on or not      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getoutputstatus(this, ~)
            fprintf(this.instr, 'STATUS?');
            reply = dec2bin( fread(this.instr, 1), 8);
            
            output = str2double(reply(2));
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputstatus: turns output on or off  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setoutputstatus(this, status, varargin)
            if(nargin == 1 || ~exist('status', 'var') || isempty(status))
                error('No output status provided%s', instrerror(this, inputname(1), dbstack));
            else
                
                
                % otherwise set the status
                if(~isnumeric(status))
                    error('Output status must be 0 or 1%s', instrerror(this, inputname(1), dbstack));
                end
                
                fprintf(this.instr, 'OUT%u', status);
            end
        end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % rst: sends GPIB *RST command (i.e. resets the device)             %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            function rst(this)
                fprintf(this.instr, '*RST');
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % idn: gets GPIB identity                                           %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            function output = idn(this)
                fprintf(this.instr, '*IDN?');
                output = fscanf(this.instr, '%s');
            end
            
        end
    end
