% HP34401A.m

%------------------------------------------------------------------------------%
% HP/Agilent 34401A multimeter driver file
% This file is a matlab object that represents the 34401A. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% configure: sets the device in the measurement mode requested
% trigger: triggers the device to measure, seperated from readoutput functionality
% because this can take some time
% readoutput: reads the configured output after a trigger event
% detband: changes the detection band filter (3, 20, 200 Hz)
% integrationtime: changes the integration time for measurement (unfinished)


%------------------------------------------------------------------------------%

classdef HP34401A < common	%generate new class for HP34401A and make it a subclass of common
    
    
    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
    end
    
    
    methods
        
        %constructor (i.e. creator class, called by default)
        function obj = HP34401A(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
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
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % readoutput: Reads the output of the device after a trigger event  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = detband(this, detband)
            
            if( ~exist('detband', 'var') || isempty(detband) )
                fprintf(this.instr, 'DET:BAND?');
                output = fscanf(this.instr, '%f');
            else
                if( ~ismember(detband, [3, 20, 200]) )
                    error('Detection band can only be 3 Hz, 20 Hz, or 200 Hz');
                end
                fprintf(this.instr, 'DET:BAND %u', detband);
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % integrationtime: reads or sets the integration time for the       %
        % current configuration                                             %
        % nplc is the measurement integration time in number of power line  %
        % cycles                                                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = integrationtime(this, time)
            
            %in order to set NPLC properly we need to know the current
            %measurement function
            fprintf(this.instr, 'FUNC?');
            
            %function is returned in quotes so strip those away
            functiontype = strsplit(fscanf(this.instr, '%s'), '"');
            functiontype = functiontype{2};
            
            
            if( ~exist('time', 'var') || isempty(time) )
                fprintf(this.instr, sprintf('%s:NPLC?', functiontype));
                output = fscanf(this.instr, '%f');
            else
                
                if(isnumeric(time))
                    fprintf(this.instr, sprintf('%s:NPLC %f', functiontype, time));
                else
                    switch time
                        case 'fast4'
                            fprintf(this.instr, '%s:NPLC 0.02', functiontype);
                        case 'slow4'
                            fprintf(this.instr, '%s:NPLC 0.2', functiontype);
                        case 'fast5'
                            fprintf(this.instr, '%s:NPLC 1', functiontype);
                        case 'slow5'
                            fprintf(this.instr, '%s:NPLC 10', functiontype);
                        case 'fast6'
                            fprintf(this.instr, '%s:NPLC 10', functiontype);
                        case 'slow6'
                            fprintf(this.instr, '%s:NPLC 100', functiontype);
                        otherwise
                            error('Unrecognised NPLC amount');
                    end
                end
            end
            
        end
    end
    
end
