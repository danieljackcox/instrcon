% stanford research systems SRS-830 lock-in amplifier instrument control driver

classdef SR830 < handle	%generate new class for SRS830 and make it a subclass of handle


    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        ADDR	%gpib address
        CHAN	%DC output or measurement channel
        instr
        V
    end


    methods

        %constructor (i.e. creator class, called by default)
        function obj = SR830
            %nothing
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % voltage: sets or reads a DC voltage on one of the   %
        % auxilliary (output) channels                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = voltage(obj, V, channel)

            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number');
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:4) )
                error('Channel number must be between 1 and 4');
            end

            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                fprintf(obj.instr, sprintf('AUXV? %d', channel));
                output = fscanf(obj.instr, '%f');
            else

                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number');
                end

                fprintf(obj.instr, sprintf('AUX V %d, %f', channel, V));

            end
        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ref: sets the device to use internal or external    %
        % frequency reference or queries to get the ref       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = ref(obj, ref)
            if( nargin == 1 || isempty(ref) )
                fprintf(obj.instr, 'FMOD?');
                output = fscanf(obj.instr, '%d');
            else

                if( ~isnumeric(ref))
                    error('Provided reference must be an integer or logical');
                end

                % passes all error checking, then execute
                fprintf(obj.instr, 'FMOD %d', ref);

            end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % freq: sets or reads internal frequency              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = freq(obj, freq)

            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(freq) )
                fprintf(obj.instr, 'FREQ?');
                output = fscanf(obj.instr, '%f');
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(freq))
                    error('Provided frequency must be a real number');
                end

                fprintf(obj.instr, 'FREQ %f', freq);

            end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reftrig: sets the reference trigger to sine zero crossing       %
        % , TTL rising edge or TTL falling edge, also queries for current %
        % setting                                                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = reftrig(obj, trigtype)

            %if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(trigtype) )
                fprintf(obj.instr, 'RSLP?');
                output = fscanf(obj.instr, '%d');
            else
                % otherwise we set the value

                % check that it is a real number
                if( ~isnumeric(trigtype))
                    error('Provided reference trigger must be an integer between 0 and 2');
                end
                % and check that the number is 0, 1, or 2
                if( ~ismember(trigtype, 0:2) )
                    error('Input must be 0, 1, or 2');
                end

                fprintf(obj.instr, 'RSLP %d', trigtype);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % harmonic: sets or returns the measurement harmonic           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = harmonic(obj, harmonic)
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(harmonic) )
                fprintf(obj.instr, 'HARM?');
                output = fscanf(obj.instr, '%d');
            else
                % otherwise check if passed value is a number then set it
                if( ~isnumeric(harmonic))
                    error('Harmonic must be an integer larger than 1');
                end


                fprintf(obj.instr, 'HARM %d', harmonic);

            end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % excitation: sets or returns the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = excitation(obj, excitation)

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(excitation) )
                fprintf(obj.instr, 'SLVL?');
                output = fscanf(obj.instr, '%f');
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number');
                end

                %set the excitation
                fprintf(obj.instr, 'SLVL %f', excitation);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % inputconfig: sets or reads the device input configuration, choose  %
        % between 0 (A), 1 (A-B), 2 (I 1MOhm), 3 (100 MOhm)                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = inputconfig(obj, inputconfig)

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(inputconfig) )
                fprintf(obj.instr, 'ISRC?');
                output = fscanf(obj.instr, '%d');
            else

                % check if passed value is a number, and then check if it is
                % in the accepted range
                if( ~isnumeric(inputconfig))
                    error('Input Configuration must be a number');
                end

                if( ~ismember(inputconfig, 0:3) )
                    error('Input must be 0, 1, 2, or 3');
                end

                % set the value
                fprintf(obj.instr, 'ISRC %d', inputconfig);

            end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % shieldgrounding: Sets or reads the input shield to be        %
        % floating (0) or grounded (1)                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = shieldgrounding(obj, shieldground)

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(shieldground) )
                fprintf(obj.instr, 'IGND?');
                output = fscanf(obj.instr, '%d');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(shieldground))
                    error('Input Shield Grounding must be a number');
                end

                if( ~ismember(shieldground, [0 1]) )
                    error('Input must be 0 or 1');
                end

                % set the value
                fprintf(obj.instr, 'IGND %d', shieldground);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % notchfilter: sets or reads the input line notch filter status %
        % no filters (0), 1x line freq (1), 2x line freq (2) or both (3)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = notchfilter(obj, notchfilter)

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(notchfilter) )
                fprintf(obj.instr, 'ILIN?');
                output = fscanf(obj.instr, '%d');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(notchfilter))
                    error('Notch Filter must be a number');
                end

                if( ~ismember(notchfilter , 0:3) )
                    error('Input must be between 0 and 3');
                end

                % set the value
                fprintf(obj.instr, 'ILIN %d', notchfilter);

            end

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % sensitivity: sets or reads the sensitivity. The input or return %
        % is an integer that corresponds to a sensitivity listed below    %
        % 0       2 nV/fA             13          50 ?V/pA                %
        % 1       5 nV/fA             14          100 ?V/pA               %
        % 2       10 nV/fA            15          200 ?V/pA               %
        % 3       20 nV/fA            16          500 ?V/pA               %
        % 4       50 nV/fA            17          1 mV/nA                 %
        % 5       100 nV/fA           18          2 mV/nA                 %
        % 6       200 nV/fA           19          5 mV/nA                 %
        % 7       500 nV/fA           20          10 mV/nA                %
        % 8       1 ?V/pA             21          20 mV/nA                %
        % 9       2 ?V/pA             22          50 mV/nA                %
        % 10      5 ?V/pA             23          100 mV/nA               %
        % 11      10 ?V/pA            24          200 mV/nA               %
        % 12      20 ?V/pA            25          500 mV/nA               %
        %                             26          1 V/?A                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = sensitivity(obj, sensitivity)

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(sensitivity) )
                fprintf(obj.instr, 'SENS?');
                output = fscanf(obj.instr, '%d');
            else

                % check if number, then check range is correct
                if( ~isnumeric(sensitivity))
                    error('Sensitivity must be a number');
                end

                if( ~ismember(sensitivity, 0:26) )
                    error('Input must be an integer between 0 and 26');
                end

                % set the value
                fprintf(obj.instr, 'SENS %d', sensitivity);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reserve: sets or reads the reserve value, high (0), normal (1) %
        % or low noise (2)                                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = reserve(obj, reserve)

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(reserve) )
                fprintf(obj.instr, 'RMOD?');
                output = fscanf(obj.instr, '%d');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(reserve) )
                    error('Reserve must be a number');
                end

                if( ~ismember(reserve , 0:2) )
                    error('Input must be between 0 and 2');
                end

                % set the value
                fprintf(obj.instr, 'RMOD %d', reserve);

            end

        end




    end
end
