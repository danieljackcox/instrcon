% SR830.m
%
%------------------------------------------------------------------------------%
% Stanford Research Systems SR830 Lock-in Amplifier driver file
% This file is a matlab object that represents the SR830. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
%
% Properties are variables that are part of this pseudo-device and represent
% real-world setting and values such as the current voltage
%
% Methods are functions used to access the abilities of the device
% for example setting a voltage or reading in a resistance value
% current methods (functions) are listed below:
%
% setoutputvoltage: sets dc voltage on AUX output
% getoutputvoltage: reads current set dc voltage on AUX output
% getinputvoltage: reads voltage from aux input
% setfreqref: sets internal or external reference
% getfreqref: reads current set reference type
% setphase: sets phase shift
% getphase: reads phase shift
% setfreq: set AC excitation frequency
% getfreq: reads AC excitation frequency
% setreftrig: sets whether to use sine or TTL reference trigger
% getreftrig: reads reference trigger type
% setharmonic: set measurement harmonic
% getharmonic: read measurement harmonic
% setexcitation: set AC excitation voltage
% getexcitation: read current set AC excitation voltage
% setinputconfig: set the input configuration (A, A-B, I, etc.)
% getinputconfig: read the input configuration
% setshieldgrounding: set shield grounding configuration
% getshieldgrounding: read shield grounding configuration
% setnotchfilter: set the notch filter configuration
% getnotchfilter: read the notch filter configuration
% setsensitivity: set the sensitivity
% getsensitivity: read the sensitivity
% setreserve: set reserve
% getreserve: read reserve
% settc: set time constant
% gettc: read time constant
% setlpfilterslope: set low pass filter slope
% getlpfilterslope: read low pass filter slope
% setsyncfilter: set synchronous filter status
% getsyncfilter: read synchronous filter status
% readoutput: reads X, Y, R, phase components from the input


%------------------------------------------------------------------------------%

classdef SR830 < voltagesource	%generate new class for SR830 and make it a subclass
% of voltagesource


    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        phaseoffset;
        inputground;
        harmonic;
        inputconfig;
        notchfilter;
        reserve;
        tc;
        filterslope;
        syncfilter;
        inputcoupling;
    end


    methods

        %constructor (i.e. creator class, called by default)
        function obj = SR830(instr, noreset)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;

            if(exist('noreset', 'var'))
                if(~isnumeric(noreset))
                    error('Noreset must be an integer\n Device SR830 at GPIB %d', obj.instr.PrimaryAddress);
                end
            else
                noreset = 0;
            end

            if(noreset == 1)
                %do absolutely nothing
            else
                %fprintf(obj.instr, '*RST');
            end



            obj.getsettings;

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputvoltage: sets or reads a DC voltage on one of the        %
        % auxilliary (output) channels                                      %
        % IMPORTANT: setoutputvoltage can return the *set*                  %
        % voltage value, it does not measure any voltage                    %                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setoutputvoltage(this, V, channel)

            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number\n Device SR830 "%s" at %d', inputname(1), this.instr.PrimaryAddress);
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:4) )
                error('Channel number must be between 1 and 4\n Device SR830 "%s" at %d', inputname(1), this.instr.PrimaryAddress);
            end
            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage passed');

            else

                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number\n Device SR830 "%s" at %d', inputname(1), this.instr.PrimaryAddress);
                end

                fprintf(this.instr, sprintf('AUX V %d, %f', channel, V));

            end
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputvoltage: reads the current set voltage on the specified  %
        % AUX out channel                                                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getoutputvoltage(this, channel)

            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number\n Device SR830 "%s" at %d', inputname(1), this.instr.PrimaryAddress);
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:4) )
                error('Channel number must be between 1 and 4\n Device SR830 "%s" at %d', inputname(1), this.instr.PrimaryAddress);
            end

            %if we got this far then everything should be fine
            fprintf(this.instr, sprintf('AUXV? %d', channel));
            output = fscanf(this.instr, '%f');
        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getinputvoltage: reads the DC voltage on the aux input %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getinputvoltage(this, channel)

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

            % read the voltage and output
            fprintf(this.instr, sprintf('OAUX? %d', channel));
            output = fscanf(this.instr, '%f');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setfreq: sets the output AC frequency     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setfreq(this, freq)

                if( ~isnumeric(freq))
                    error('Provided frequency!!');
                end

                % passes all error checking, then execute
                fprintf(this.instr, 'FREQ %f', freq);

        end



         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getfreq: gets the output AC frequency (set value)     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getfreq(this)

                fprintf(this.instr, 'FREQ?');
                output = fscanf(this.instr, '%f');

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setfreqref: sets the device to use internal or external    %
        % frequency reference                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setfreqref(this, ref)

                if( ~isnumeric(ref))
                    error('Provided reference must be an integer or logical');
                end

                % passes all error checking, then execute
                fprintf(this.instr, 'FMOD %d', ref);

        end



         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getfreqref: gets the device reference setting       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getfreqref(this)

                fprintf(this.instr, 'FMOD?');
                output = fscanf(this.instr, '%d');

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setphase: sets phase shift                    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setphase(this, phase)

            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(phase) )
                error('No phase provided');
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(phase))
                    error('Provided phase must be a real number');
                end

                fprintf(this.instr, 'PHAS %f', phase);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getphase: reads phase shift                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getphase(this)


                fprintf(this.instr, 'PHAS?');
                output = fscanf(this.instr, '%f');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setreftrig: sets the reference trigger to sine zero crossing,   %
        % TTL rising edge or TTL falling edge                             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setreftrig(this, trigtype)

            %if empty or nonexistent then return an error
            if( nargin == 1 || isempty(trigtype) )
                error('No Reference Type provided');
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

                fprintf(this.instr, 'RSLP %d', trigtype);

            end

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getreftrig: reads the reference trigger setting                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getreftrig(this)


                fprintf(this.instr, 'RSLP?');
                output = fscanf(this.instr, '%d');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setharmonic: sets the measurement harmonic           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setharmonic(this, harmonic)
            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(harmonic) )
                error('No harmonic provided');
            else
                % otherwise check if passed value is a number then set it
                if( ~isnumeric(harmonic))
                    error('Harmonic must be an integer larger than 1');
                end


                fprintf(this.instr, 'HARM %d', harmonic);

            end

        end


         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getharmonic: returns the measurement harmonic           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getharmonic(this)

                fprintf(this.instr, 'HARM?');
                output = fscanf(this.instr, '%d');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setexcitation: sets the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setexcitation(this, excitation)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided');
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number');
                end

                %set the excitation
                fprintf(this.instr, 'SLVL %f', excitation);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getexcitation: returns the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getexcitation(this)


                fprintf(this.instr, 'SLVL?');
                output = fscanf(this.instr, '%f');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setinputconfig: sets the device input configuration, choose  %
        % between 0 (A), 1 (A-B), 2 (I 1MOhm), 3 (100 MOhm)                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setinputconfig(this, inputconfig)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(inputconfig) )
                error('No input config provided');
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
                fprintf(this.instr, 'ISRC %d', inputconfig);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getinputconfig: reads the device input configuration, choose  %
        % between 0 (A), 1 (A-B), 2 (I 1MOhm), 3 (100 MOhm)                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getinputconfig(this)


                fprintf(this.instr, 'ISRC?');
                output = fscanf(this.instr, '%d');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setshieldgrounding: Sets the input shield to be        %
        % floating (0) or grounded (1)                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setshieldgrounding(this, shieldground)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(shieldground) )
                error('No ground shield configuration provided');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(shieldground))
                    error('Input Shield Grounding must be a number');
                end

                if( ~ismember(shieldground, [0 1]) )
                    error('Input must be 0 or 1');
                end

                % set the value
                fprintf(this.instr, 'IGND %d', shieldground);

            end

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getshieldgrounding: reads the input shield to be        %
        % floating (0) or grounded (1)                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getshieldgrounding(this)

                fprintf(this.instr, 'IGND?');
                output = fscanf(this.instr, '%d');

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setnotchfilter: sets the input line notch filter status %
        % no filters (0), 1x line freq (1), 2x line freq (2) or both (3)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setnotchfilter(this, notchfilter)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(notchfilter) )
                error('no notch filter provided');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(notchfilter))
                    error('Notch Filter must be a number');
                end

                if( ~ismember(notchfilter , 0:3) )
                    error('Input must be between 0 and 3');
                end

                % set the value
                fprintf(this.instr, 'ILIN %d', notchfilter);

            end

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getnotchfilter: reads the input line notch filter status %
        % no filters (0), 1x line freq (1), 2x line freq (2) or both (3)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getnotchfilter(this)


                fprintf(this.instr, 'ILIN?');
                output = fscanf(this.instr, '%d');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setsensitivity: sets the sensitivity. The input                 %
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

        function setsensitivity(this, sensitivity)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(sensitivity) )
                error('no sensitivity provided');
            else

                % check if number, then check range is correct
                if( ~isnumeric(sensitivity))
                    error('Sensitivity must be a number');
                end

                if( ~ismember(sensitivity, 0:26) )
                    error('Input must be an integer between 0 and 26');
                end

                % set the value
                fprintf(this.instr, 'SENS %d', sensitivity);

            end

        end





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getsensitivity: reads the sensitivity. The return               %
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

        function output = getsensitivity(this)


                fprintf(this.instr, 'SENS?');
                output = fscanf(this.instr, '%d');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setreserve: sets the reserve value, high (0), normal (1) %
        % or low noise (2)                                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setreserve(this, reserve)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(reserve) )
                error('no reserve provided');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(reserve) )
                    error('Reserve must be a number');
                end

                if( ~ismember(reserve , 0:2) )
                    error('Input must be between 0 and 2');
                end

                % set the value
                fprintf(this.instr, 'RMOD %d', reserve);

            end

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getreserve: reads the reserve value, high (0), normal (1) %
        % or low noise (2)                                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getreserve(this)


                fprintf(this.instr, 'RMOD?');
                output = fscanf(this.instr, '%d');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % settc: sets the time constant. The input                        %
        % is an integer that corresponds to a time constant listed below  %
        % tip: during measurement the settling time is at least 5 times   %
        % the set TC                                                      %
        % 0       10 ??s             10          1 s                       %
        % 1       30 ??s             11          3 s                       %
        % 2       100 ??s            12          10 s                      %
        % 3       300 ??s            13          30 s                      %
        % 4       1 ms              14          100 s                     %
        % 5       3 ms              15          300 s                     %
        % 6       10 ms             16          1 ks                      %
        % 7       30 ms             17          3 ks                      %
        % 8       100 ms            18          10 ks                     %
        % 9       300 ms            19          30 ks                     %
        %                                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function settc(this, tc)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(tc) )
                error('no tc provided');
            else

                % check if number, then check range is correct
                if( ~isnumeric(tc))
                    error('Time Constant must be a number');
                end

                if( ~ismember(tc, 0:19) )
                    error('Input must be an integer between 0 and 19');
                end

                % set the value
                fprintf(this.instr, 'OFLT %d', tc);

            end

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % gettc: reads the time constant. The return                      %
        % is an integer that corresponds to a time constant listed below  %
        % tip: during measurement the settling time is at least 5 times   %
        % the set TC                                                      %
        % 0       10 ??s             10          1 s                       %
        % 1       30 ??s             11          3 s                       %
        % 2       100 ??s            12          10 s                      %
        % 3       300 ??s            13          30 s                      %
        % 4       1 ms              14          100 s                     %
        % 5       3 ms              15          300 s                     %
        % 6       10 ms             16          1 ks                      %
        % 7       30 ms             17          3 ks                      %
        % 8       100 ms            18          10 ks                     %
        % 9       300 ms            19          30 ks                     %
        %                                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = gettc(this)


                fprintf(this.instr, 'OFLT?');
                output = fscanf(this.instr, '%d');

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setlpfilterslope: sets the low-pass filter slope,        %
        % 6 dB/oct (0), 12 dB/oct (1), 18 dB/oct (2), 24 dB/oct (3)      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setlpfilterslope(this, lpfilterslope)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(lpfilterslope) )
                error('no filter slope provided');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(lpfilterslope) )
                    error('Filter slope must be a number');
                end

                if( ~ismember(lpfilterslope , 0:3) )
                    error('Input must be between 0 and 3');
                end

                % set the value
                fprintf(this.instr, 'OFSL %d', lpfilterslope);

            end

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getlpfilterslope: reads the low-pass filter slope,        %
        % 6 dB/oct (0), 12 dB/oct (1), 18 dB/oct (2), 24 dB/oct (3)      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getlpfilterslope(this)


                fprintf(this.instr, 'OFSL?');
                output = fscanf(this.instr, '%d');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setsyncfilter: sets the synchronous filter status           %
        % OFF (0) or ON (1), only operates below excitation frequecy 200 Hz %
        % worth keeping on                                                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setsyncfilter(this, syncfilter)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(syncfilter) )
                error('no sync filter provided');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(syncfilter) )
                    error('Sync filter status must be a number');
                end

                if( ~ismember(syncfilter , 0:1) )
                    error('Input must be 0 or 1');
                end

                % set the value
                fprintf(this.instr, 'SYNC %d', syncfilter);

            end

        end





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getsyncfilter: reads the synchronous filter status           %
        % OFF (0) or ON (1), only operates below excitation frequecy 200 Hz %
        % worth keeping on                                                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getsyncfilter(this)


                fprintf(this.instr, 'SYNC?');
                output = fscanf(this.instr, '%d');


        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setinputcoupling: sets the input coupling                   %
        % AC (0) or DC (1)                                                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setinputcoupling(this, inputcoupling)

            % if empty or nonexistent then return an error
            if( nargin == 1 || isempty(inputcoupling) )
                error('no input coupling provided');
            else

                % check if number, then check if in correct range
                if( ~isnumeric(inputcoupling) )
                    error('Input coupling must be a number');
                end

                if( ~ismember(inputcoupling , 0:1) )
                    error('Input must be 0 or 1');
                end

                % set the value
                fprintf(this.instr, 'ICPL %d', inputcoupling);

            end

        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getinputcoupling: reads the input coupling                   %
        % AC (0) or DC (1)                                                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getinputcoupling(this)


                fprintf(this.instr, 'ICPL?');
                output = fscanf(this.instr, '%d');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % readoutput: returns the AC input values (X, Y, R, phase)          %
        % note: the values for X, Y and R, phase are recorded approx 10 uS  %
        % apart. This should only be important at ultra-short time constants%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [X, Y, R, phase] = readoutput(this)

            % dont need to do anything except ask the device for the
            % values
            fprintf(this.instr, 'SNAP? 1,2,3,4');
            tmp_output = scanstr(this.instr, ',', '%f');

            % assign tmp_output to proper variables just for readability
            X       = tmp_output(1);
            Y       = tmp_output(2);
            R       = tmp_output(3);
            phase   = tmp_output(4);

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getsettings: executes other functions in this file and returns    %
        % a formatted list of the current device settings                   %
        % n.b. this function does not directly return values but rather     %
        % sets the object properties!                                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function getsettings(this)
            %get the settings
            phaseoffset = this.getphase;
            inputground = this.getshieldgrounding;
            harmonic = this.getharmonic;
            inputconfiguration = this.getinputconfig;
            inputcoupling = this.getinputcoupling;
            notchfilter = this.getnotchfilter;
            reserve = this.getreserve;
            tc = this.gettc;
            filterslope = this.getlpfilterslope;
            syncfilter = this.getsyncfilter;

            %make a human-readable list of settings
            inputconfig_text = {'A','A-B','I (10MOhm)','I (100MOhm)'};
            inputground_text = {'float','ground'};
            inputcoupling_text = {'AC','DC'};
            notchfilter_text = {'none','50Hz','100Hz','50+100Hz'};
            reserve_text = {'high','normal','low noise'};
            timeconstant_text = {'10us','30us','100us','300us','1ms','3ms','10ms','30ms','100ms','300ms','1s','3s','10s','30s','100s','300s','1ks','3ks','10ks','30ks'};
            filterslope_text = {'6dB/oct','12dB/oct','18dB/oct','24dB/oct'};
            syncfilter_text = {'off','on'};

            %commit the changes

            this.phaseoffset = phaseoffset;
            this.inputground = inputground_text{inputground + 1};
            this.harmonic = harmonic;
            this.inputconfig = inputconfig_text{inputconfiguration+1};
            this.notchfilter = notchfilter_text{notchfilter+1};
            this.reserve = reserve_text{reserve+1};
            this.tc = timeconstant_text{tc+1};
            this.filterslope = filterslope_text{filterslope+1};
            this.syncfilter = syncfilter_text{syncfilter+1};
            this.inputcoupling = inputcoupling_text{inputcoupling+1};





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
            fprintf(this.instr, 'IDN?');
            output = fscanf(this.instr, '%s');
        end

    end
end
