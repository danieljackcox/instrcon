%opendevice.m
% open function, will open gpib device, identify it and return correct
% device driver object
% vend and bus are optional arguments
function handle = opendevice(addr, varargin)

addpath('drivers');
addpath('functions');
% make sure matlab can see the contents
% of the drivers folder

%import the identities and drivers supported
run('drivers/identities.m');



if(~any(addr))
    error('No address provided');
end

if(isempty(varargin))
    % if varargin is empty then someone just called the open
    % command with no inputs at all, throw an error
    error('No connection type provided (must be gpib, tcpip, visa, etc.) for address %s', addr);
end


% someone must provide the connection type when they open the
% device, so search the input arguments and compare to our
% allowed (supported) types

allowedtypes = {'gpib', 'serial', 'tcpip', 'usb', 'visa'};
allowedvendors = {'agilent', 'ni', 'tek'};

%array preallocation always good when using for loops
typematch = zeros(length(nargin)-2);


%this for loop is required because 'ismember' doesn't work with
%mixed cell arrays (that we might have)
for i=1:nargin-2
    
    if(ischar(varargin{i}))
        typematch(i) = ismember(varargin{i}, allowedtypes);
    end
    
end

vendoridx = find(strcmpi('vendor', varargin));
busidx = find(strcmpi('bus', varargin));


%if no vendor given then default to ni
if(~any(vendoridx))
    vend = 'ni';
else
    
    %if a vendor is not supported then throw an error
    if(~ismember(varargin{vendoridx+1}, allowedvendors))
        error('Vendor type not supported address %s', addr);
    end
    
    %otherwise everything ok
    vend = varargin{vendoridx+1};
end



%if no bus is given then default to 0 (gpib only)
if(~any(busidx))
    bus = 0;
else
    bus = varargin{busidx+1};
end

%if no connection type given then throw an error
if(~any(typematch))
    error('Connection type not recognised address %s', addr);
end
if(length(typematch) > 1)
    error('Multiple connection types given address %s', addr);
end


% now generate the instrument object depending on the type
% given
switch varargin{typematch}
    case 'gpib'
        instr = visa(vend, sprintf('GPIB0::%d::%d::INSTR', addr, bus));
    case 'serial'
        instr = visa(vend, sprintf('ASRL%d::INSTR', addr));
    case 'tcpip'
        instr = visa(vend, sprintf('TCPIP::%s::INSTR', addr));
    case 'visa'
        instr = visa(vend, addr);
    otherwise
        error('Connection type not supported address %s', addr);
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
    warning('No match found for device\n IDN: %s\nAddress: %s', identity, addr);
    handle = instr;
else
    
    %call that object and return the correct handle
    handle = this.drivers{drivernumber}(instr);
    
end

end