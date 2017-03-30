%common.m

% this file contains all common methods used in basic instrument control
% and measurement
% OPEN : Opens a GPIB device, identifies and returns device object
classdef common < handle
    
    properties
        verb = 0; % verbosity, off by default
        drivers;
        idns;
    end
    
    methods
        % constructor object
        function obj = common
            addpath('drivers');
            addpath('functions');
            % make sure matlab can see the contents
            % of the drivers folder
            
            %import the identities and drivers supported
            run('drivers/identities.m');
        end
        
    end
    
    methods
        
        % open function, will open gpib device, identify it and return correct
        % device driver object
        % vend and bus are optional arguments
        function handle = open(this, addr, varargin)
            
            if(isempty(varargin))
                % if varargin is empty then someone just called the open
                % command with no inputs at all, throw an error
                error('No input provided');
            end
            
            
            % someone must provide the connection type when they open the
            % device, so search the input arguments and compare to our
            % allowed (supported) types
            
            allowedtypes = {'gpib', 'serial', 'tcpip', 'usb', 'visa'};
            allowedvendors = {'agilent', 'ni', 'tek'};
            
            %array preallocation always good when using for loops
            typematch = zeros(length(nargin)-2);
            vendormatch = zeros(length(nargin)-2);
            busmatch = zeros(length(nargin)-2);
            
            
            %this for loop is required because 'ismember' doesn't work with
            %mixed cell arrays (that we might have)
            for i=1:nargin-2
                
                if(ischar(varargin{i}))
                    typematch(i) = find(ismember(varargin, allowedtypes));
                    vendormatch(i) = find(ismember(varargin, 'vendor'));
                    busmatch(i) = find(ismember(varargin, 'bus'));
                end
                
            end
            
            typeidx = find(typematch);
            vendoridx = find(vendormatch);
            busidx = find(busmatch);
            
            
            %if no vendor given then default to ni
            if(~any(vendoridx))
                vend = 'ni';
            else
                
                %if a vendor is not supported then throw an error
                if(~ismember(varargin{vendoridx+1}, allowedvendors))
                    error('Vendor type not supported');
                end
            end
            
            
            
            %if no bus is given then default to 0 (gpib only)
            if(~any(busidx))
                bus = 0;
            else
                bus = varargin{busidx+1};
            end
            
            
            
            % now generate the instrument object depending on the type
            % given
            switch varargin{typeidx+1}
                case 'gpib'
                    instr = visa(vend, sprintf('GPIB::%d::%d::INSTR', addr, bus));
                case 'serial'
                    instr = visa(vend, sprintf('ASRL%d::INSTR', addr));
                case 'tcpip'
                    instr = visa(vend, sprintf('TCPIP::%s::INSTR', addr));
                case 'visa'
                    instr = visa(vend, addr);
                otherwise
                    error('Connection type not supported');
            end
            
            
            try
                fopen(instr);
            catch
                % CHANGE THIS ERROR
                error('Cannot open GPIB device at address %s', num2str(addr));
            end
            
            % assuming everything went well we can then
            % flush input and output buffers, this is important on certain devices
            % such as SR830
            flushinput(instr); %software buffers
            flushoutput(instr);
            clrdevice(instr); % hardware buffers
            
            % print a confirmation message if the option is chosen
            if( this.verb == 1 )
                fprintf(1, 'Device opened at %s (GPIB)', num2str(addr));
            end
            
            %query device for its identity
            identity = query(instr, '*IDN?');
            
            %match to a driver object
            matches = zeros(size(this.idns));
            for i=1:length(this.idns)
                matches(i) = ~isempty(strfind(identity, this.idns{i}));
            end
            
            drivernumber = find(matches);
            
            if(isempty(drivernumber))
                error('No match found for device\n IDN: %s', identity);
            end
            
            %call that object and return the correct handle
            handle = this.drivers{drivernumber}(instr);
            
        end
        
        
        
        function dcvoltage(obj, voltage, channel, imm, stepsize, speed)
            run('functions/dcvoltage.m');
        end
        
        
    end
    
end
