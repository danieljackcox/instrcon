if( nargin == 0 )
        error('No arguments passed');
    end

    if( ~exist('obj', 'var') || isempty(obj) )
        error('A device object must be passed');
    end

    if( ~exist('imm', 'var') || isempty(imm) )
        if( ~ismember(imm, 0:1) )
            error('imm must be 0 or 1');
        end
        imm = 0;
    end

    if( ~exist('channel', 'var') || isempty(channel) )
        if( ~isnumeric(channel) )
            error('Channel must be a number');
        end
        channel = 1;
    end

%    if( ~exists(range_change) || isempty(range_change) )
%        if( ~ismember(range_change, 0:1) )
%            error('range_change must be 0 or 1');
%        end
%        range_change = 0;
%    end

    if( ~exist('stepsize', 'var') || isempty(stepsize) )
        if( ~isnumeric(stepsize) )
            error('Step size must be a number');
        end
        stepsize = 50e-3;
    end

    if( ~exist('speed', 'var') || isempty(speed) )
        if( ~isnumeric(speed) )
            error('Speed must be a number');
        end
        speed = 10e-3;
    end




    current_voltage = obj.readvoltage(channel);

    if( current_voltage == voltage )
        %no nothing
    else

        if( imm == 1)
            obj.setvoltage(voltage, channel);
        else
            rampvoltage = linspace(current_voltage, voltage, round(abs(diff([current_voltage voltage]))/stepsize)+1);

            for i=1:rampvoltage
                obj.setvoltage(rampvoltage(i), channel);
                java.lang.Thread.sleep(1000*speed);
            end

        end
    end
