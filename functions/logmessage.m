% logmessage.m
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
% Function displays messages and sends those messages to the log depending
% on the verbose and logging settings
% LOGMESSAGE(message_level, obj, message)
% message_level is the verbose level at which the message should be
% displayed, i.e. if message is level 2 then it will only be displayed when
% verbose is set to 2 or higher
% obj is the object that message was called from
% message is the formatted message that should be printed
% verbose levels are:
% 0 only errors
% 1 instrument connect and disconnect
% 2 everything

function logmessage(message_level, this, message)

% check if the message should be displayed or not
if( message_level <= this.verbose )
    time_of_day = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    fprintf(1, sprintf('|%s| > %s\n', time_of_day, message));
    
    % handle the logging part
    if( this.logging == 1 )
        
        settings = getsettings;
        if( settings.dynamic_log_path == 1 )
            
            current_date = datestr(now, 'yyyy-mm-dd');
            
            % first check if the folder exists and make it if it doesn't
            if( exist(sprintf('%s/%s', settings.data_path, current_date), 'file') == 0)
                try
                    mkdir(sprintf('%s/%s', settings.data_path, current_date));
                catch
                    % n.b. create an error here
                end
            end
            
            if( settings.combined_logs == 1 )
                fid = fopen(sprintf('%s/%s/log.log', settings.data_path, current_date), 'a');
            else
                fid = fopen(sprintf('%s/%s/%s.log', settings.data_path, current_date, class(this)), 'a');
            end
            if(fid == -1)
                error('Unable to open log file'); % n.b. fix this to be more like other errors
            end
            
            fprintf(fid, sprintf('|%s| > %s\r\n', time_of_day, message));
            fclose(fid);
        else
            % first check if the folder exists and make it if it doesn't
            if( exist(settings.log_path, 'file') == 0)
                try
                    mkdir(settings.log_path);
                catch
                    % n.b. create an error here
                end
            end
            
            if( settings.combined_logs == 1 )
                fid = fopen(sprintf('%s/log.log', settings.log_path), 'a');
            else
                fid = fopen(sprintf('%s/%s.log', settings.data_path, class(this)), 'a'); % n.b. update name of log
            end
            if(fid == -1)
                error('Unable to open log file'); % n.b. fix this to be more like other errors
            end
            
            fprintf(fid, sprintf('%s > %s\r\n', time_of_day, message));
            fclose(fid);
        end
    end
end







end
