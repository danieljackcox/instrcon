% K2450.m
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

classdef K2450 < common	%generate new class for K2450 and make it a subclass of handle


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
        % configure: reads or sets the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = configure(this, type)

            % if no arguments provided then return the current config
            if( nargin == 1 )
                fprintf(this.instr, 'SOUR:FUNC?');
                output = fscanf(this.instr, '%s');

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
        % setvoltage: sets or reads a DC voltage                            %
        % IMPORTANT: setvoltage can return the *set* voltage value, it does %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = setvoltage(this, V, ~)

            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                fprintf(this.instr, 'SOUR:VOLT?');
                output = fscanf(this.instr, '%f');
            else

                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number');
                end

                fprintf(this.instr, sprintf('SOUR:VOLT %f', V));
                fprintf(this.instr, 'TRAC:TRIG');

            end
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
