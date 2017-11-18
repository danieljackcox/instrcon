% HP34401A.m
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
% HP/Agilent 34401A multimeter driver file
% This file is a matlab object that represents the 34401A. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% configure: sets the device in the measurement mode requested
% trigger: triggers the device to measure, seperated from getmeas functionality
% because this can take some time
% getmeas: reads the configured output after a trigger event
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
        % setconf: sets the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setconf(this, type, range, resolution)

            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('No arugments provided');

            else
                switch type
                    
                    %n.b. check if these still work...

                    % if type is dcvolt then configure for DC voltage measurement
                    case 'dcvolt'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:VOLT:DC', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:VOLT:DC');
                        end

                        % if type is acvolt then configure for AC voltage measurement
                    case 'acvolt'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:VOLT:AC', '%f', '%f', range, resolution);
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
                            fprintf(this.instr, 'CONF:CURR:AC', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:CURR:AC');
                        end
                        % if type is res then configure for resistance measurement
                    case 'res'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:RES', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:RES');
                        end
                        % if type is 4res then configure for 4-probe resistance measurement
                    case '4res'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:FRES', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:FRES');
                        end
                        % if type is freq then configure for frequency measurement
                    case 'freq'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:FREQ', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:FREQ');
                        end
                        % if type is per then configure for period measurement
                    case 'per'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:PER', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:PER');
                        end
                        % if type is cont then configure for continuity measurement
                    case 'cont'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:CONT', '%f', '%f', range, resolution);
                        else
                            fprintf(this.instr, 'CONF:CONT');
                        end
                        % if type is diode then configure for diode measurement
                    case 'diode'
                        if( exist('range', 'var') && exist('resolution', 'var') && ~isempty(range) && ~isempty(resolution) )
                            fprintf(this.instr, 'CONF:DIOD', '%f', '%f', range, resolution);
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
        % getconf: reads the measurement type                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function output = getconf(this)


                fprintf(this.instr, 'CONF?');
                output = fscanf(this.instr, '%s');

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
        % getmeas: Reads the output of the device after a trigger event  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getmeas(this)
            output = fscanf(this.instr, '%f');
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setdetband: sets the detection bandwidth                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setdetband(this, detband)

            if( ~exist('detband', 'var') || isempty(detband) )
                error('No arguments provided');
            else
                if( ~ismember(detband, [3, 20, 200]) )
                    error('Detection band can only be 3 Hz, 20 Hz, or 200 Hz');
                end
                fprintf(this.instr, 'DET:BAND %u', detband);
            end

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getdetband: reads the detection bandwidth                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getdetband(this)


                fprintf(this.instr, 'DET:BAND?');
                output = fscanf(this.instr, '%f');


        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setintegrationtime: sets the integration time for the             %
        % current configuration                                             %
        % nplc is the measurement integration time in number of power line  %
        % cycles                                                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setintegrationtime(this, time)

            %in order to set NPLC properly we need to know the current
            %measurement function
            fprintf(this.instr, 'FUNC?');

            %function is returned in quotes so strip those away
            functiontype = strsplit(fscanf(this.instr, '%s'), '"');
            functiontype = functiontype{2};


            if( ~exist('time', 'var') || isempty(time) )
                error('No arguments provided');
            else

                if(isnumeric(time))
                    fprintf(this.instr, '%s:NPLC %f', functiontype, time);
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



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getintegrationtime: reads or sets the integration time for the    %
        % current configuration                                             %
        % nplc is the measurement integration time in number of power line  %
        % cycles                                                            %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getintegrationtime(this)

            %in order to set NPLC properly we need to know the current
            %measurement function
            fprintf(this.instr, 'FUNC?');

            %function is returned in quotes so strip those away
            functiontype = strsplit(fscanf(this.instr, '%s'), '"');
            functiontype = functiontype{2};


            fprintf(this.instr, '%s:NPLC?', functiontype);
            output = fscanf(this.instr, '%f');

        end



    end

end
