% HP33120A.m

%------------------------------------------------------------------------------%
% HP/Agilent/keysight 33120A function generator driver file
% This file is a matlab thisect that represents the 33120A. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% setvoltage: set or read dc voltage
% readvoltage: reads voltage from aux input
% ref: set or read internal or external reference
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

classdef HP33120A < common	%generate new class for SRS830 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
        V
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = HP33120A
            %nothing
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % configure: sets the output function type.                         %
        % Choose from sine, square, triangle, ramp, noise, dc               %
        % arbitrary waveforms not implemented
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = configure(this, type)
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                fprintf(this.instr, 'CONF?');
                output = fscanf(this.instr, '%s');
                
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
                fprintf(this.instr, 'VOLT:OFFS?');
                output = fscanf(this.instr, '%f');
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number');
                end
                
                fprintf(this.instr, sprintf('VOLT:OFFS %f', V));
                
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % freq: sets or reads internal frequency              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = freq(this, freq)
            
            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(freq) )
                fprintf(this.instr, 'FREQ?');
                output = fscanf(this.instr, '%f');
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(freq))
                    error('Provided frequency must be a real number');
                end
                
                fprintf(this.instr, 'FREQ %f', freq);
                
            end
            
        end
      
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % excitation: sets or returns the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = excitation(this, excitation)
            
            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(excitation) )
                fprintf(this.instr, 'VOLT?');
                output = fscanf(this.instr, '%f');
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number');
                end
                
                %set the excitation
                fprintf(this.instr, 'VOLT %f', excitation);
                
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
            fprintf(this.instr, 'IDN?');
            output = fscanf(this.instr, '%s');
        end
        
    end
end
