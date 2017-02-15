% SR830.m
%
%------------------------------------------------------------------------------%
% Stanford Research Systems SR830 Lock-in Amplifier driver file
% This file is a matlab thisect that represents the SR830. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% setvoltage: set or read dc voltage
% readvoltage: reads voltage from aux input
% freqref: set or read internal or external reference
% phase: sets or reads phase shift
% freq: set or read frequency
% reftrig: sine or TTL reference input
% harmonic: set or read harmonic
% excitation: set or read AC excitation voltage
% inputconfig: set or read the input configuration
% shieldgrounding: set or read shield grounding configuration
% notchfilter: set or read the notch filter configuration
% sensitivity: set or read the sensitivity
% reserve: set or read reserve
% tc: set or read time constant
% lpfilterslope: set or read low pass filter slope
% syncfilter: set or read synchronous filter status
% readoutput: reads X, Y, R, phase components from the input


%------------------------------------------------------------------------------%

classdef SR830 < common	%generate new class for SRS830 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr;
        setting;
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = SR830(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
            
            %set instrument into known state
            if noreset exists then
                dont reset
            else
                do reset
            end
            
            %now record the initial settings
            record;
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setvoltage: sets or reads a DC voltage on one of the              %
        % auxilliary (output) channels                                      %
        % IMPORTANT: setvoltage can return the *set* voltage value, it does %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = setvoltage(this, V, channel)
            
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
                fprintf(this.instr, sprintf('AUXV? %d', channel));
                output = fscanf(this.instr, '%f');
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number');
                end
                
                fprintf(this.instr, sprintf('AUX V %d, %f', channel, V));
                
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % readvoltage: reads the DC voltage on the aux input %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = readvoltage(this, channel)
            
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
        % ref: sets the device to use internal or external    %
        % frequency reference or queries to get the ref       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = ref(this, ref)
            if( nargin == 1 || isempty(ref) )
                fprintf(this.instr, 'FMOD?');
                output = fscanf(this.instr, '%d');
            else
                
                if( ~isnumeric(ref))
                    error('Provided reference must be an integer or logical');
                end
                
                % passes all error checking, then execute
                fprintf(this.instr, 'FMOD %d', ref);
                
            end
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % freqref: sets the device to use internal or external    %
        % frequency reference or queries to get the ref       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = freqref(this, ref)
            if( nargin == 1 || isempty(ref) )
                fprintf(this.instr, 'FMOD?');
                output = fscanf(this.instr, '%d');
            else
                
                if( ~isnumeric(ref))
                    error('Provided reference must be an integer or logical');
                end
                
                % passes all error checking, then execute
                fprintf(this.instr, 'FMOD %d', ref);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % phase: sets or reads phase shift                    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = phase(this, phase)
            
            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(phase) )
                fprintf(this.instr, 'PHAS?');
                output = fscanf(this.instr, '%f');
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(phase))
                    error('Provided phase must be a real number');
                end
                
                fprintf(this.instr, 'PHAS %f', phase);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reftrig: sets the reference trigger to sine zero crossing       %
        % , TTL rising edge or TTL falling edge, also queries for current %
        % setting                                                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = reftrig(this, trigtype)
            
            %if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(trigtype) )
                fprintf(this.instr, 'RSLP?');
                output = fscanf(this.instr, '%d');
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % harmonic: sets or returns the measurement harmonic           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = harmonic(this, harmonic)
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(harmonic) )
                fprintf(this.instr, 'HARM?');
                output = fscanf(this.instr, '%d');
            else
                % otherwise check if passed value is a number then set it
                if( ~isnumeric(harmonic))
                    error('Harmonic must be an integer larger than 1');
                end
                
                
                fprintf(this.instr, 'HARM %d', harmonic);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % excitation: sets or returns the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = excitation(this, excitation)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(excitation) )
                fprintf(this.instr, 'SLVL?');
                output = fscanf(this.instr, '%f');
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number');
                end
                
                %set the excitation
                fprintf(this.instr, 'SLVL %f', excitation);
                
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % inputconfig: sets or reads the device input configuration, choose  %
        % between 0 (A), 1 (A-B), 2 (I 1MOhm), 3 (100 MOhm)                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = inputconfig(this, inputconfig)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(inputconfig) )
                fprintf(this.instr, 'ISRC?');
                output = fscanf(this.instr, '%d');
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % shieldgrounding: Sets or reads the input shield to be        %
        % floating (0) or grounded (1)                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = shieldgrounding(this, shieldground)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(shieldground) )
                fprintf(this.instr, 'IGND?');
                output = fscanf(this.instr, '%d');
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % notchfilter: sets or reads the input line notch filter status %
        % no filters (0), 1x line freq (1), 2x line freq (2) or both (3)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = notchfilter(this, notchfilter)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(notchfilter) )
                fprintf(this.instr, 'ILIN?');
                output = fscanf(this.instr, '%d');
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
        
        function output = sensitivity(this, sensitivity)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(sensitivity) )
                fprintf(this.instr, 'SENS?');
                output = fscanf(this.instr, '%d');
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reserve: sets or reads the reserve value, high (0), normal (1) %
        % or low noise (2)                                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = reserve(this, reserve)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(reserve) )
                fprintf(this.instr, 'RMOD?');
                output = fscanf(this.instr, '%d');
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
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % tc: sets or reads the time constant. The input or return        %
        % is an integer that corresponds to a time constant listed below  %
        % tip: during measurement the settling time is at least 5 times   %
        % the set TC                                                      %
        % 0       10 μs             10          1 s                       %
        % 1       30 μs             11          3 s                       %
        % 2       100 μs            12          10 s                      %
        % 3       300 μs            13          30 s                      %
        % 4       1 ms              14          100 s                     %
        % 5       3 ms              15          300 s                     %
        % 6       10 ms             16          1 ks                      %
        % 7       30 ms             17          3 ks                      %
        % 8       100 ms            18          10 ks                     %
        % 9       300 ms            19          30 ks                     %
        %                                                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = tc(this, tc)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(tc) )
                fprintf(this.instr, 'OFLT?');
                output = fscanf(this.instr, '%d');
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
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % lpfilterslope: sets or reads the low-pass filter slope,        %
        % 6 dB/oct (0), 12 dB/oct (1), 18 dB/oct (2), 24 dB/oct (3)      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = lpfilterslope(this, lpfilterslope)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(lpfilterslope) )
                fprintf(this.instr, 'OFSL?');
                output = fscanf(this.instr, '%d');
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % syncfilter: sets or reads the synchronous filter status           %
        % OFF (0) or ON (1), only operates below excitation frequecy 200 Hz %
        % worth keeping on                                                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = syncfilter(this, syncfilter)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(syncfilter) )
                fprintf(this.instr, 'SYNC?');
                output = fscanf(this.instr, '%d');
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
        % inputcoupling: sets or reads the input coupling                   %
        % AC (0) or DC (1)                                                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = inputcoupling(this, inputcoupling)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(inputcoupling) )
                fprintf(this.instr, 'ICPL?');
                output = fscanf(this.instr, '%d');
            else
                
                % check if number, then check if in correct range
                if( ~isnumeric(inputcoupling) )
                    error('Input coupling must be a number');
                end
                
                if( ~ismember(inputcoupling , 0:1) )
                    error('Input must be 0 or 1');
                end
                
                % set the value
                fprintf(this.instr, 'ICPL %d', syncfilter);
                
            end
            
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
            phaseoffset = this.phase;
            inputground = this.shieldgrounding;
            harmonic = this.harmonic;
            inputconfiguration = this.inputconfig;
            inputcoupling = this.inputcoupling;
            notchfilter = this.notchfilter;
            reserve = this.reserve;
            tc = this.tc;
            filterslope = this.lpfilterslope;
            syncfilter = this.syncfilter;
            
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
            
            this.setphaseoffset = phaseoffset;
            this.setinputground = inputground_text{inputground + 1};
            this.setharmonic = harmonic;
            this.setinputconfig = inputconfig_text{inputconfiguration+1};
            this.setnotchfilter = notchfilter_text{notchfilter+1};
            this.setreserve = reserve_text{reserve+1};
            this.settc = timeconstant_text{tc+1};
            this.setfilterslope = filterslope_text{filterslope+1};
            this.setsyncfilter = syncfilter_text{syncfilter+1};
            this.setinputcoupling = inputcoupling_text{inputcoupling+1};
            
            
            
            
            
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
