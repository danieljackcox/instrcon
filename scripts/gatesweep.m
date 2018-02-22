%Program measures resistance via single lock-in and applies gate voltage
%Only for current bias schemes
try
    instrreset;
    warning('off','all');
    clear;
    addpath('functions', 'drivers');
    
catch
    error('Error closing devices');
end
%%%%%%%%%%%%%%%%%%%%%%%%
% Edit variables below %
%%%%%%%%%%%%%%%%%%%%%%%%

%name of file
name = 'gate sweep 2_AB34_03_17_highres';

%Bias voltage range given to DC source
gatevoltage =[0 1];
gatevoltage = repmat(gatevoltage, 1, 500);

%notes about the measurement for future reference
note = 'switching between 0 and 1 volts to see if a repeatable resistance shows up';

%set only a single value here
biasvoltage = 0;

%gains on the amplifiers
voltgain = 10;
currgain = 1e5;

%ballast resistances used
ACres = 1e6;

%Lock-in settings
LIAvoltage = 1.0;
LIAfrequency = 5.6;

%length of pauses between measurements in seconds
pauselength =  2.5;

%open required devices
voltlia  = opendevice(11);
currlia = opendevice(10);
gate     = opendevice(3);
bias = voltlia;

%%%%%%%%%%%%%%%%%%%%%
% Do not edit below %
%%%%%%%%%%%%%%%%%%%%%


%configure LIA
%arg: devicehandle, internal/external reference, frequency, excitation
voltlia.setfreq(LIAfrequency);
voltlia.setexc(LIAvoltage);
currlia.setfreqref('ext');

%record LIA settings used
voltliasettings = readsettings(voltlia);
currliasettigns = readsettings(currlia);

%preallocate matricies for speed
acvoltx = zeros(1,length(gatevoltage))*NaN;
acvolty = zeros(1,length(gatevoltage))*NaN;
acvoltr = zeros(1,length(gatevoltage))*NaN;
acvoltphase = zeros(1,length(gatevoltage))*NaN;

accurrx = zeros(1,length(gatevoltage))*NaN;
accurry = zeros(1,length(gatevoltage))*NaN;
accurrr = zeros(1,length(gatevoltage))*NaN;
accurrphase = zeros(1,length(gatevoltage))*NaN;

temperature = zeros(1,length(gatevoltage))*NaN;

%this is a variable that contains all of the stuff we do NOT want to save
donotsave = '^(?!(gate|bias|currlia|voltlia|noiselia|voltdvm|currdvm|noisedvm|magnet|f1|f2|p1|p2|p3|p4|p5|donotsave|name)$).';


%save the file now
save(name, '-regexp', donotsave);

%also create a backup file and save that
save(sprintf('%s_backup',name), '-regexp', donotsave);

%initialise figure here because it's much faster
f1 = figure;
set(f1,'name','DC Gate Sweep','numbertitle','off');
p1 = plot(gatevoltage,acvolt.r./accurr.r,'.-');
xlabel('DC gate Voltage (V)');ylabel('dVdI (\Omega)');
set(p1, 'XDataSource','gatevoltage','YDataSource','acvolt.r./accurr.r');
drawnow;

%a friendly message
fprintf(1, '\nBeginning measurement %s', datestr(now, 'HHMM'));
%begin time estimation
tic;

%%%%%%%%%%%%%
% main loop %
%%%%%%%%%%%%%

%If there is a desired bias, set it here
if(isa(bias, 'gpib') == 1)
    setvoltage(bias, biasvoltage);
end

for g=1:length(gatevoltage)
    
    %set gate bias voltage
    setvoltage(gate, gatevoltage(g));
    
    %pause to let devices stabilise, etc.
    java.lang.Thread.sleep(pauselength*1000);
    
    %trigger measurement
    triggerlia(voltlia);
    triggerlia(currlia);
    
    %read LIA
    [acvolt.r(g), acvolt.x(g), acvolt.y(g), acvolt.phase(g)] = readlia(voltlia);
    [accurr.r(g), accurr.x(g), accurr.y(g), accurr.phase(g)] = readlia(currlia);
    
    %read temperature
    temperature(g) = sampletemperature;
    
    %correct for gains and calculate current
    acvolt.x(g) = acvolt.x(g)/voltgain;
    acvolt.y(g) = acvolt.y(g)/voltgain;
    acvolt.r(g) = acvolt.r(g)/voltgain;
    
    accurr.x(g) = accurr.x(g)/currgain;
    accurr.y(g) = accurr.y(g)/currgain;
    accurr.r(g) = accurr.r(g)/currgain;
    
    %save file
    save(name, '-regexp', donotsave);
    
    figure(f1);
    title(datestr((abs((toc/(g)*length(gatevoltage)) - toc))/86400,'dd HH:MM:SS'), 'Interpreter','none');
    set(p1, 'XData', gatevoltage, 'YData', acvolt.r./accurr.r);
    drawnow limitrate;
    
    %save the backup
    save(sprintf('%s_backup',name), '-regexp', donotsave);
    
end

%save the figure(s)
print(f1, name, '-dtiff');

%make sure gate is at zero
setvoltage(gate,0);
if(isa(bias, 'gpib'))
    setvoltage(bias, 0);
end
instrreset; %close all devices

%delete the backup
delete(sprintf('%s_backup', name));

fprintf(1, '\nMeasurement ended %s\n', datestr(now, 'HHMM'));


