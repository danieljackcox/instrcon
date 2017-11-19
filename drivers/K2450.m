% K2450.m
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
% Keithley Sourcemeter 2450 driver file
% This file is a matlab object that represents the 2450. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% configure: configure the device for volt or current measurement
% setvoltage: sets DC voltage or reads current set voltage
% readoutput: depending on how the device is configured, reads voltage, current, resistance


%------------------------------------------------------------------------------%

classdef K2450 < voltagesource	%generate new class for K2450 and make it a subclass of handle


    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
        V
    end


    methods

        %constructor (i.e. creator class, called by default)
        function obj = K2450(instr)
            obj.instr = instr;
            fprintf(obj.instr, '*RST');
            fprintf(obj.instr, 'SOUR:FUNC VOLT');
            fprintf(obj.instr, 'SENS:FUNC "CURR"');
            fprintf(obj.instr, 'SOUR:VOLT:READ:BACK ON');
            fprintf(obj.instr, 'SOUR:VOLT 0');
            fprintf(obj.instr, 'OUTP ON');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setconf: sets the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setconf(this, type)

            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('No arguments provided');

            else
                switch type
                    case 'dcvolt'
                        fprintf(this.instr, 'SOUR:FUNC VOLT');

                    case 'dccurr'
                        fprintf(this.instr, 'SOUR:FUNC CURR');

                    otherwise
                        error('Unrecognised type');

                end

            end

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getconf: reads the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getconf(this)

                fprintf(this.instr, 'SOUR:FUNC?');
                output = fscanf(this.instr, '%s');


        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setvoltage: sets a DC voltage                            %                                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function getvoltage(this, V, ~)

            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No arguments provided');
            else

                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number');
                end

                fprintf(this.instr, 'SOUR:VOLT %f', V);
                fprintf(this.instr, 'TRAC:TRIG');

            end
        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getvoltage: reads a DC voltage                            %
        % IMPORTANT: getvoltage can return the *set* voltage value, it does %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getvoltage(this)


                fprintf(this.instr, 'SOUR:VOLT?');
                output = fscanf(this.instr, '%f');
        
        end




       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % readoutput: sends a read command and then reads the output of    %
        % the device, in this case V, I and R                              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = readoutput(this)
            fprintf(this.instr, 'READ?');
            output = fscanf(this.instr, '%f');


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
