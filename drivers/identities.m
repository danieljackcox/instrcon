% identities.m
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
% This file contains the identities (SCPI *IDN command) of supported
% devices in the variable obj.idns and the corresponding driver functions
% in the obj.drivers variable.
% 
% To add a driver you must select a unique part of the *IDN response that
% does not contain device serial numbers and the like and then add the name
% of the driver object in the same order as is listed in the idns variable.

idns = {'Stanford_Research_Systems,SR830'; 'HEWLETT-PACKARD,34401A'; ...
    'HEWLETT-PACKARD,33120A'; 'KEITHLEY INSTRUMENTS INC.,MODEL 2400'; ...
    'KEITHLEY INSTRUMENTS INC.,MODEL 2450'; 'Stanford_Research_Systems,SR785'; ...
    'Agilent Technologies,33210A'; 'Agilent Technologies,33522A'; ...
    'HP8656B'; 'KORADKA3005PV2.0'};


drivers = {@SR830, @HP34401A, @HP33120A, @K2400, @K2450, @SR785, ...
    @HP33120A, @A33522A, @HP8656B, @TENMA};
