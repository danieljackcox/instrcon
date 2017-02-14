%common.m

% this file contains all common methods used in basic instrument control
% and measurement
% OPEN : Opens a GPIB device, identifies and returns device object
classdef common < handle
    
    properties
        verb = 0; % verbosity, off by default
        addr; % address of device
        vend; % board vendor, by default 'ni'
        bus; % bus number, by default 0
    end
    
    methods
        % constructor object
        function obj = common
            addpath('drivers');
            addpath('functions');
            % make sure matlab can see the contents
            % of the drivers folder
            obj;
        end
        
    end
    
    methods
        
        % open function, will open gpib device, identify it and return correct
        % device driver object
        % vend and bus are optional arguments
        function handle = open(obj, addr, vend, bus)
            
            % if no address is given then show an error
            if(~exist('addr', 'var'))
                error('Address must be given');
            end
            
            
            % if no board is given then set a default here
            if(~exist('vend', 'var'))
                vend = 'ni';
            end
            
            
            % is no bus is given then set default here
            if(~exist('bus', 'var'))
                bus = 0;
            end
            
            
            %%%
            % now do some sanity checks on variables that have been passed
            %%%
            
            
            % check if the vendor passed is a character array
            if(~ischar(vend))
                error('Vendor id should be a character array (addr: %s)', num2str(addr));
            end
            
            % make sure bus is a number
            if(~isnumeric(bus))
                error('Bus should be a number (addr: %s)', num2str(addr));
            end
            
            % make sure address is a number
            if(~isnumeric(addr))
                error('Address should be a number');
            end
            
            % matlab only supports four vendor types, so we make sure that
            % the type passed is one of those
            if( ~(strcmpi(vend, 'ni')||strcmpi(vend, 'agilent')||strcmpi(vend, 'ics')||strcmpi(vend, 'mcc')) )
                error('Unrecognised vendor type (addr: %s)', num2str(addr));
            end
            
            
            
            %%%
            % GPIB object creation and opening
            %%%
            
            
            % create a gpib object with the passed variables (or defaults)
            % and assign it to a temporary variable so we can open it
            try
                instr = gpib(vend, bus, addr);
                fopen(instr);
            catch
                error('Cannot open GPIB device at address %s', num2str(addr));
            end
            
            % assuming everything went well we can then
            % flush input and output buffers, this is important on certain devices
            % such as SR830
            flushinput(instr); %software buffers
            flushoutput(instr);
            clrdevice(instr); % hardware buffers
            
            % print a confirmation message if the option is chosen
            if( obj.verb == 1 )
                fprintf(1, 'Device opened at %s (GPIB)', num2str(ADDR));
            end
            
            %query device for its identity
            identity = query(instr, '*IDN?');
            
            % UNFINISHED, only supports SR830
            if( ~isempty(strfind(identity, 'Stanford_Research_Systems,SR830')) )
                handle = SR830;
                handle.instr = instr;
                
            elseif( ~isempty(strfind(identity, 'HEWLETT-PACKARD,34401A')) )
                handle = HP34401A;
                handle.instr = instr;
                
            elseif( ~isempty(strfind(identity, 'HEWLETT-PACKARD,33120A')) )
                handle = HP33120A;
                handle.instr = instr;
                
            elseif( ~isempty(strfind(identity, 'KEITHLEY INSTRUMENTS INC.,MODEL 2400')) )
                handle = K2400;
                handle.instr = instr;
                
                elseif( ~isempty(strfind(identity, 'KEITHLEY INSTRUMENTS INC.,MODEL 2450')) )
                handle = K2450;
                handle.instr = instr;
                
            end
        end
        
        
    
    function dcvoltage(obj, voltage, channel, imm, stepsize, speed)
    if( nargin == 0 )
        error('No arguments passed');
    end
    
    if( ~exist('obj', 'var') || isempty(obj) )
        error('A device object must be passed');
    end
    
    if( ~exist('imm', 'var') || isempty(imm) )
        imm = 0;
    end
    
    if( ~ismember(imm, 0:1) )
        error('imm must be 0 or 1');
    end
    
    if( ~exist('channel', 'var') || isempty(channel) )
        channel = 1;
    end
    
    if( ~isnumeric(channel) )
        error('Channel must be a number');
    end
    
    %    if( ~exists(range_change) || isempty(range_change) )
    %        if( ~ismember(range_change, 0:1) )
    %            error('range_change must be 0 or 1');
    %        end
    %        range_change = 0;
    %    end
    
    if( ~exist('stepsize', 'var') || isempty(stepsize) )
        stepsize = 50e-3;
    end
    
    if( ~isnumeric(stepsize) )
        error('Step size must be a number');
    end
    
    if( ~exist('speed', 'var') || isempty(speed) )
        speed = 10e-3;
    end
    
    if( ~isnumeric(speed) )
        error('Speed must be a number');
    end
    
    
    current_voltage = obj.setvoltage([], channel);
    
    
    if( current_voltage == voltage )
        %no nothing
    else
        
        if( imm == 1)
            obj.setvoltage(voltage, channel);
        else
            rampvoltage = linspace(current_voltage, voltage, round(abs(diff([current_voltage voltage]))/stepsize)+1);
            for i=1:length(rampvoltage)
                obj.setvoltage(rampvoltage(i), channel);
                java.lang.Thread.sleep(1000*speed);
            end
            
        end
    end
    end
    
    
end

end
