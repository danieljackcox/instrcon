%common.m

% this file contains all common methods used in basic instrument control
% and measurement
% OPEN : Opens a GPIB device, identifies and returns device object
classdef common < handle

properties
	VERB = 0; % verbosity, off by default
    ADDR;
    BOARD;
    BUS;
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
    function handle = open(obj, ADDR, BOARD, BUS)
        % BOARD and BUS are optional arguments
       
        if(~exist('ADDR', 'var'))
            % if no address is given then show an error
            error('Address must be given');
        end
        
        if(~exist('BOARD', 'var'))
            % if no board is given then set a default here
            BOARD = 'ni';
        end
        
        if(~exist('BUS', 'var'))
            % is no bus is given then set default here
            BUS = 0;
        end

		%first check that the variables passed are ok
		if(~ischar(BOARD))
			error('Board id should be a character array');
		end
		if(~isnumeric(BUS))
			error('Bus should be a number');
		end
		if(~isnumeric(ADDR))
			error('Address should be a number');
		end

		% finish later if strcmpi(BOARD, )
        INSTR = gpib(BOARD, BUS, ADDR);
        fopen(INSTR);
        
        %query device
        identity = query(INSTR, '*IDN?');
        
        if(~isempty(strfind(identity, 'Stanford_Research_Systems,SR830')))
            handle = SR830;
            handle.instr = INSTR;
        end


end

end

end