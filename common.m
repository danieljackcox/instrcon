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
	obj;
end

end

methods

% open function, will open gpib device, identify it and return correct
% device driver object
function handle = open(obj, addr, vend, bus)
	% BOARD and BUS are optional arguments

	if(~exist('addr', 'var'))
		% if no address is given then show an error
		error('Address must be given');
	end

	if(~exist('vend', 'var'))
		% if no board is given then set a default here
		vend = 'ni';
	end

	if(~exist('bus', 'var'))
		% is no bus is given then set default here
		bus = 0;
	end

	% first check that the variables passed are ok
	if(~ischar(vend))
		% check if the vendor passed is a character array
		error('Vendor id should be a character array');
	end
	if(~isnumeric(bus))
		% make sure bus is a number
		error('Bus should be a number');
	end
	if(~isnumeric(addr))
		% make sure address is a number
		error('Address should be a number');
	end

	if( ~strcmpi(vend, 'ni')||~strcmpi(vend, 'agilent')||~strcmpi(vend, 'ics')||~strcmpi(vend, 'mcc') )
		% make sure the vendor is of a type recognised by matlab
		error('Unrecognised vendor type');
	end

	% create the gpib object and then open it
	try
		instr = gpib(vend, bus, addr);
		fopen(instr);
	catch
		error('Cannot open GPIB device at address %s', num2str(addr));
	end

	% flush input and output buffers, this is important on certain devices
	% such as SR830
	flushinput(devicehandle); %software buffers
	flushoutput(devicehandle);
	
	% print a confirmation message if the option is chosen
	if( verb == 1 )
		fprintf(1, 'Device opened at %s (GPIB)', num2str(ADDR));
	end

	%query device for its identity
	identity = query(instr, '*IDN?');

	if(~isempty(strfind(identity, 'Stanford_Research_Systems,SR830')))
		handle = SR830;
		handle.instr = instr;
	end


end

end

end
