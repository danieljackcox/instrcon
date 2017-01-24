% K2400.m

%------------------------------------------------------------------------------%
% Keithley Sourcemeter 2400 driver file
% This file is a matlab thisect that represents the 2400. It provides standard
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

classdef K2400 < common	%generate new class for SRS830 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
        V
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = K2400
            %nothing
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % configure: reads or sets the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = configure(this, type)
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                fprintf(this.instr, ':CONF?');
                output = fscanf(this.instr, '%s');
                
            else
                switch type
                    case 'dcvolt'
                        fprintf(this.instr, ':CONF:VOLT:DC');
                        
                    case 'dccurr'
                        fprintf(this.instr, ':CONF:CURR:DC');
                        
                    case 'res'
                        fprintf(this.instr, ':CONF:RES');
                        
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
                fprintf(this.instr, ':SOUR:VOLT?');
                output = fscanf(this.instr, '%f');
            else
                
                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number');
                end
                
                fprintf(this.instr, sprintf(':SOUR:VOLT %f', V));
                
            end
        end
        
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % readoutput: sends a read command and then reads the output of    %
        % the device                                                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [voltage, current, resistance] = readoutput(this)
            fprintf(this.instr, ':READ?');
            
            tmp_output = scanstr(this.instr, ',', '%f');
            
            %any value returned which equals 9.91e37 is not a number so
            %lets redefine it here
            tmp_output(tmp_output == 9.91e37) = NaN;
            
            voltage = tmp_output(1);
            current = tmp_output(2);
            resistance = tmp_output(3);
            
            
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
