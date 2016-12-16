% stanford research systems SRS-830 lock-in amplifier instrument control driver

classdef SR830 < handle	%generate new class for SRS830 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    properties
        ADDR	%gpib address
        CHAN	%DC output or measurement channel
        instr
        V
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = SR830(ADDR)
            %nothing
        end
        
        function volts = voltage(obj, V, channel)
            
            % check that the channel variable is ok first
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number');
                end
            else
                channel = 1;
            end
            
            if(channel < 1 || channel > 4)
                error('Channel number must be between 1 and 4');
            end
            
            % if nothing or only channel is being passed then return the
            % voltage set
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                fprintf(obj.instr, sprintf('AUXV? %d', channel));
                volts = fscanf(obj.instr, '%f');
            else
                
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
            if( nargin == 1 || isempty(freq) )
                fprintf(obj.instr, 'FREQ?');
                output = fscanf(obj.instr, '%f');
            else
                
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
            if( nargin == 1 || isempty(trigtype) )
                fprintf(obj.instr, 'RSLP?');
                output = fscanf(obj.instr, '%d');
            else
                
                if( ~isnumeric(trigtype))
                    error('Provided reference trigger must be an integer between 0 and 2');
                end
                
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
            if( nargin == 1 || isempty(harmonic) )
                fprintf(obj.instr, 'HARM?');
                output = fscanf(obj.instr, '%d');
            else
                
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
            if( nargin == 1 || isempty(excitation) )
                fprintf(obj.instr, 'SLVL?');
                output = fscanf(obj.instr, '%f');
            else
                
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number');
                end
                
                
                fprintf(obj.instr, 'SLVL %f', excitation);
                
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % inputconfig: sets or reads the device input configuration, choose  %
        % between 0 (A), 1 (A-B), 2 (I 1MOhm), 3 (100 MOhm)                  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = inputconfig(obj, inputconfig)
            if( nargin == 1 || isempty(inputconfig) )
                fprintf(obj.instr, 'ISRC?');
                output = fscanf(obj.instr, '%d');
            else
                
                if( ~isnumeric(inputconfig))
                    error('Input Configuration must be a number');
                end
                
                if( ~ismember(inputconfig, 0:3) )
                    error('Input must be 0, 1, 2, or 3');
                end
                
                
                fprintf(obj.instr, 'ISRC %d', inputconfig);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % shieldgrounding: Sets or reads the input shield to be        %
        % floating (0) or grounded (1)                                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = shieldgrounding(obj, shieldground)
            if( nargin == 1 || isempty(shieldground) )
                fprintf(obj.instr, 'IGND?');
                output = fscanf(obj.instr, '%d');
            else
                
                if( ~isnumeric(shieldground))
                    error('Input Shield Grounding must be a number');
                end
                
                if( ~ismember(shieldground, [0 1]) )
                    error('Input must be 0 or 1');
                end
                
                
                fprintf(obj.instr, 'IGND %d', shieldground);
                
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % notchfilter: sets or reads the input line notch filter status %
        % no filters (0), 1x line freq (1), 2x line freq (2) or both (3)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = notchfilter(obj, notchfilter)
            if( nargin == 1 || isempty(notchfilter) )
                fprintf(obj.instr, 'ILIN?');
                output = fscanf(obj.instr, '%d');
            else
                
                if( ~isnumeric(notchfilter))
                    error('Notch Filter must be a number');
                end
                
                if( ~ismember(notchfilter , 0:3) )
                    error('Input must be between 0 and 3');
                end
                
                
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
            if( nargin == 1 || isempty(sensitivity) )
                fprintf(obj.instr, 'SENS?');
                output = fscanf(obj.instr, '%d');
            else
                
                if( ~isnumeric(sensitivity))
                    error('Sensitivity must be a number');
                end
                
                if( ~ismember(sensitivity, 0:26) )
                    error('Input must be an integer between 0 and 26');
                end
                
                
                fprintf(obj.instr, 'SENS %d', sensitivity);
                
            end
            
        end
        
        
        function output = iden(obj)
            output = query(obj.instr, '*IDN?');
        end
    end
end
