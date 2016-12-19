% HP34401A.m

%------------------------------------------------------------------------------%
% HP/Agilent 34401A multimeter driver file
% This file is a matlab object that represents the 34401A. It provides standard
% methods that interface with the device so the specific code required for          % communicating with the device over GPIB is not needed.
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

classdef HP34401A < handle	%generate new class for SRS830 and make it a subclass of handle
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = HP34401A
            %nothing
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % configure: reads or sets the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = configure(this, type, range, resolution)
            
            % if no arguments provided then return the current config
            if( nargin == 1 )
                fprintf(this.instr, 'CONF?');
                output = fscanf(this.instr, '%s');
                
            else
                switch type
                    
                    % if type is dcvolt then configure for DC voltage measurement
                    case 'dcvolt'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:VOLT:DC', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:VOLT:DC');
                        end
                        
                        % if type is acvolt then configure for AC voltage measurement
                    case 'acvolt'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:VOLT:AC', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:VOLT:AC');
                        end
                        % if type is dccurr then configure for DC current measurement
                    case 'dccurr'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:CURR:DC', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:CURR:DC');
                        end
                        % if type is accurr then configure for AC voltage measurement
                    case 'accurr'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:CURR:AC', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:CURR:AC');
                        end
                        % if type is res then configure for resistance measurement
                    case 'res'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:RES', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:RES');
                        end
                        % if type is 4res then configure for 4-probe resistance measurement
                    case '4res'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:FRES', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:FRES');
                        end
                        % if type is freq then configure for frequency measurement
                    case 'freq'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:FREQ', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:FREQ');
                        end
                        % if type is per then configure for period measurement
                    case 'per'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:PER', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:PER');
                        end
                        % if type is cont then configure for continuity measurement
                    case 'cont'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:CONT', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:CONT');
                        end
                        % if type is diode then configure for diode measurement
                    case 'diode'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, sprintf('CONF:DIOD', '%f', '%f', range, resolution));
                        else
                            fprintf(this.instr, 'CONF:DIOD');
                        end
                        % if type isnt matched then throw an error
                    otherwise
                        error('Unrecognised type');
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % trigger: Triggers the dvm to start a measurement                  %
        % this is done seperately from the reading because measurements     %
        % can take several seconds, completely freezing the matlab main     %
        % thread                                                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function trigger(this)
            fprintf(this.instr, 'INIT;FETC?');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % readoutput: Reads the output of the device after a trigger event  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = readoutput(this)
            output = fscanf(this.instr, '%f');
        end
        
    end
end
