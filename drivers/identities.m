% identities.m
%
% This file contains the identities (GPIB *IDN command) of supported
% devices in the variable obj.idns and the corresponding driver functions
% in the obj.drivers variable.
% 
% To add a driver you must select a unique part of the *IDN response that
% does not contain device serial numbers and the like and then add the name
% of the driver object in the same order as is listed in the idns variable.

obj.idns = {'Stanford_Research_Systems,SR830'; 'HEWLETT-PACKARD,34401A'; ...
    'HEWLETT-PACKARD,33120A'; 'KEITHLEY INSTRUMENTS INC.,MODEL 2400'; ...
    'KEITHLEY INSTRUMENTS INC.,MODEL 2450'};


obj.drivers = {@SR830, @HP34401A, @HP33120A, @K2400, @K2450};