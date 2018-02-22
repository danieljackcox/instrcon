%opendevice.m
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
% open function, will open gpib device, identify it and return correct
% device driver object
% OPENDEVICE(address, 'addrtype', 'vendor', vendorstring, 'bus', busstring)

function handle = opendevice(addr, varargin)

addpath('../drivers');
addpath('../functions');
% make sure matlab can see the contents
% of the drivers folder

%import the identities and drivers supported
run('identities.m');



if(~any(addr))
    error('No address provided');
end

if(isempty(varargin))
    % if varargin is empty then someone just called the open
    % command with no connection type defined, choose gpib by default
end


% someone must provide the connection type when they open the
% device, so search the input arguments and compare to our
% allowed (supported) types

allowedtypes = {'gpib', 'serial', 'tcpip', 'usb', 'visa'};
allowedvendors = {'agilent', 'ni', 'tek'};

%array preallocation always good when using for loops
typematch = zeros(1, nargin-1);


%this for loop is required because 'ismember' doesn't work with
%mixed cell arrays (that we might have)
for i=1:nargin-1
    
    if(ischar(varargin{i}))
        typematch(i) = ismember(varargin{i}, allowedtypes);
    end
    
end


vendoridx = find(strcmpi('vendor', varargin));
busidx = find(strcmpi('bus', varargin));
driveridx = find(strcmpi('driver', varargin));


%if no vendor given then default to first installed vendor
if(~any(vendoridx))
    visainfo = instrhwinfo('visa');
    if(isempty(visainfo.InstalledAdaptors))
        error('No vendors installed, address %s', addr);
    else
        vend = visainfo.InstalledAdaptors{1};
    end
else
    
    
    %if a vendor is not supported then throw an error
    if(~ismember(varargin{vendoridx+1}, allowedvendors))
        error('Vendor type not supported, address %s', addr);
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

%if no connection type matches check if it is invalid input
% and throw an error, if input is empty then default to gpib
if(~any(typematch))
    if(isempty(varargin))
        varargin{1} = 'gpib';
        typematch = 1;
    else
        error('Connection type not recognised address %s', addr);
    end
end

if(sum(typematch) > 1)
    error('Multiple connection types given address %s', addr);
end


% now generate the instrument object depending on the type
% given

switch varargin{typematch == 1}
    case 'gpib'
        instr = visa(vend, sprintf('GPIB%d::%d::INSTR', bus, addr));
    case 'serial'
        instr = visa(vend, sprintf('ASRL%d::INSTR', addr));
    case 'tcpip'
        instr = visa(vend, sprintf('TCPIP::%s::INSTR', addr));
    case 'usb'
        instr = visa(vend, sprintf('USB::%s::INSTR', addr));
    case 'visa'
        instr = visa(vend, addr);
    otherwise
        error('Connection type not supported address %s', addr);
end

try
    fopen(instr);
catch
    % CHANGE THIS ERROR
    error('Cannot open ''%s'' device at address %s', varargin{typematch == 1}, num2str(addr));
end

% assuming everything went well we can then
% flush input and output buffers, this is important on certain devices
% such as SR830
% flushinput(instr); %software buffers
% flushoutput(instr);
% clrdevice(instr); % hardware buffers


%n.b. fix this to correct for getting rid of common.m
% % print a confirmation message if the option is chosen
% if( this.verb == 1 )
%     fprintf(1, 'Device opened at %s', num2str(addr));
% end


% if the 'driver' flag hasn't been set then we query the device
% if it has been set then we pass that value as the identity
if(~any(driveridx))
    %query device for its identity
    identity = query(instr, '*IDN?');
    
    %match to a driver object
    matches = zeros(size(idns));
    for i=1:length(idns)
        matches(i) = ~isempty(strfind(identity, idns{i}));
    end
    
    drivernumber = find(matches);
else
    reqdriver = varargin{driveridx+1};
    driverfunchandles = cellfun(@func2str, drivers, 'UniformOutput', 0);
    drivernumber = find(strcmpi(reqdriver, driverfunchandles));
end


if(isempty(drivernumber))
    warning('No match found for device\n IDN: %s\nAddress: %s', identity, addr);
    handle = instr;
else
    %call that object and return the correct handle
    handle = drivers{drivernumber(1)}(instr);
    
end

end
