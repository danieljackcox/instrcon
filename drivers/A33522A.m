% A33522A.m
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
% HP/Agilent/keysight 33522A function generator driver file
% This file is a matlab thisect that represents the 33522A. It provides standard
% methods that interface with the device so the specific code required for
% communicating with the device over GPIB is not needed.
%
% Methods:
% setconf: configure the function generator to output the desired signal type
% getconf: returns the current configuration of the generator
% setoutputvoltage: sets the DC offset voltage
% getoutputvoltage: returns the currently set DC offset voltage
% freq: sets wave frequency for current configured type
% setexcitation: sets wave amplitude (RMS) for current configured type
% getexcitation: gets wave amplitude (RMS) for current configured type


%------------------------------------------------------------------------------%

classdef A33522A < voltagesource	%generate new class for A33522A and
    % make it a subclass of voltagesource


    %declare some basic properties (variables) for use later
    % UNFINISHED
    properties
        instr
        V
    end


    methods

        %constructor (i.e. creator class, called by default)
        function obj = A33522A(instr)
            %a gpib object is passed when creating the object, so make it
            %part of the object here
            obj.instr = instr;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setconf: sets the output function type.                           %
        % Choose from sine, square, triangle, ramp, noise, dc               %
        % arbitrary waveforms not implemented
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setconf(this, type)

            % if no arguments provided then return the current config
            if( nargin == 1 )
                error('no configuration provided%s', instrerror(this, inputname(1), dbstack));

            else
                switch type

                    % if type is dcvolt then configure for DC voltage measurement
                    case 'sine'
                            fprintf(this.instr, 'FUNC SIN');

                        % if type is acvolt then configure for AC voltage measurement
                    case 'square'
                            fprintf(this.instr, 'FUNC SQU');

                        % if type is dccurr then configure for DC current measurement
                    case 'triangle'
                            fprintf(this.instr, 'FUNC TRI');

                        % if type is accurr then configure for AC voltage measurement
                    case 'ramp'
                            fprintf(this.instr, 'FUNC RAMP');

                        % if type is res then configure for resistance measurement
                    case 'noise'
                            fprintf(this.instr, 'FUNC NOISE');

                        % if type is 4res then configure for 4-probe resistance measurement
                    case 'dc'
                            fprintf(this.instr, 'FUNC DC');

                    otherwise
                        error('Unrecognised type%s', instrerror(this, inputname(1), dbstack));
                end
            end
        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getconf: reads the output function type.                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getconf(this)


                fprintf(this.instr, 'CONF?');
                output = fscanf(this.instr, '%s');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setoutputvoltage: sets a DC voltage                               %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setoutputvoltage(this, V, channel)
            
            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number%s', instrerror(this, inputname(1), dbstack));
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end
            

            % if voltage is empty or doesn't exist then we want to return
            % the voltage value
            if(nargin == 1 || ~exist('V', 'var') || isempty(V))
                error('No voltage provided%s', instrerror(this, inputname(1), dbstack));
            else

                % otherwise set the voltage
                if(~isnumeric(V))
                    error('Voltage must be a number%s', instrerror(this, inputname(1), dbstack));
                end

                fprintf(this.instr, 'SOUR%d:VOLT:OFFS %f', channel, V);

            end
        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getoutputvoltage: reads a DC voltage                              %
        % IMPORTANT: getvoltage returns the *set* voltage value, it does    %
        % not measure any voltage                                           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getoutputvoltage(this, channel)
            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number%s', instrerror(this, inputname(1), dbstack));
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end


                fprintf(this.instr, 'SOUR%d:VOLT:OFFS?', channel);
                output = fscanf(this.instr, '%f');

        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setfreq: sets internal frequency              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setfreq(this, freq, channel)
            
            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number%s', instrerror(this, inputname(1), dbstack));
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end


            % if nothing or empty variable is passed then read the value
            % and return it
            if( nargin == 1 || isempty(freq) )
                error('No frequency provided%s', instrerror(this, inputname(1), dbstack));
            else
                % otherwise do basic sanity checking and then set the frequency
                if( ~isnumeric(freq))
                    error('Provided frequency must be a real number%s', instrerror(this, inputname(1), dbstack));
                end

                fprintf(this.instr, 'SOUR%d:FREQ %f', channel, freq);

            end

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getfreq: reads internal frequency              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getfreq(this, channel)
            
            % check that the channel variable exists first
            % if it exists, check if it is a number
            % if not then assign default value 1
            if(exist('channel', 'var'))
                if(~isnumeric(channel))
                    error('Channel must be an integer number%s', instrerror(this, inputname(1), dbstack));
                end
            else
                channel = 1;
            end

            % make sure that the channel is a number between 1 and 4
            if( ~ismember(channel, 1:2) )
                error('Channel number must be between 1 and 2%s', instrerror(this, inputname(1), dbstack));
            end



                fprintf(this.instr, 'SOUR%d:FREQ?', channel);
                output = fscanf(this.instr, '%f');


        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % setxcitation: sets the AC output sine wave voltage (in RMS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function setexcitation(this, excitation, ~)
            % for some reason this device doesn't have per channel
            % amplitude control

            % if empty or nonexistent then read and return the value
            if( nargin == 1 || isempty(excitation) )
                error('No excitation provided%s', instrerror(this, inputname(1), dbstack));
            else
                % check if passed value is a number
                if( ~isnumeric(excitation))
                    error('AC Sine Excitation must be a number%s', instrerror(this, inputname(1), dbstack));
                end

                %set the excitation
                fprintf(this.instr, 'VOLT %f', excitation);

            end

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getexcitation: returns the AC output sine wave voltage (in RMS)      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function output = getexcitation(this)


                fprintf(this.instr, 'VOLT?');
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
            fprintf(this.instr, 'IDN?');
            output = fscanf(this.instr, '%s');
        end

    end
end
