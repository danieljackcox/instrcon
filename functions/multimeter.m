%voltagesource.m
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
% this file contains high level functions used with multimeters (this can
% range from simple voltage meters to complicated multimeters) and
% defines the minimum functions a multimeter driver should expose

% minimum functions:
% getmeas

classdef multimeter < handle
    
    properties
        verb = 0; % verbosity, off by default
    end
    
    methods
        % constructor object
        function obj = multimeter
            
        end
        
        
    end
    
    methods (Abstract)
        
        getmeas(this)
        
    end
    
end
