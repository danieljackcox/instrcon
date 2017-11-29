% instrerror.m
%     Created 2017 Daniel Cox
%     Part of instrcon
%
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
% This function is used in error reporting to return the device name and
% description

function outputstring = instrerror(this, objname, stackinfo)

outputstring = sprintf('\nCalling ''%s''\nDevice ''%s'', type ''%s'' at address ''%s''', stackinfo.name, objname, class(this), this.instr.Name);
logmessage(0, this, ['ERROR: ' outputstring]);
end
