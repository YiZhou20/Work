function [links, velocities, densities, times, link_lengths] = ...
    readLDT(nid, cid, run_id, startDate, endDate, lidsStr, ...
    dataTypeOption, qty_type, app_run_id, varargin)

username = '';
password = '';

% Try to obtain the username and password from the optional input args.
if (length(varargin) == 2)
    username = varargin(1);
    password = varargin(2);
end

% If there were no username/password specified, use the login dialog.
if (isempty(username) && isempty(password))
    [username, password] = logindlg('Title', 'LOGIN');
end

import java.lang.*;
import edu.berkeley.path.readldt.*;
%import core.*;
%setEnvironment;
%setImport;

velocities = [];
densities = [];


if strcmp(dataTypeOption, 'velocity')
    data_source = 1;
elseif strcmp(dataTypeOption, 'density')
    data_source = 2;
elseif strcmp(dataTypeOption, 'inflow')
    data_source = 3;
elseif strcmp(dataTypeOption, 'outflow')
    data_source = 4;
end

global gb_conn

FromDT = datestr([startDate(1), startDate(2), startDate(3), startDate(4), startDate(5), startDate(6)], 'dd-mmm-yyyy HH:MM:SS');
ToDT = datestr([endDate(1), endDate(2), endDate(3), endDate(4), ...
    endDate(5), endDate(6)], 'dd-mmm-yyyy HH:MM:SS');

%ldt = mlReadLDTWrapper.mlReadLDT(username, password, 'localhost', nid, cid, app_run_id, run_id, ...
%    FromDT, ToDT, qty_type, data_source, lidsStr, false, 'blah.csv');
ldt = matlabReadLDT.mlReadLDT(gb_conn, nid, cid, app_run_id, run_id, ...
     FromDT, ToDT, qty_type, data_source, lidsStr, false, 'blah.csv');
links = ldt(1:end,1);
if data_source == 1 || data_source == 3                % velocity or inflow
    velocities = ldt(1:end,2);
elseif data_source == 2 || data_source == 4            % density or outflow
    densities = ldt(1:end, 2);
end
times = ldt(1:end,3);
%link_lengths = double(mlReadLDTWrapper.mlReadLDTLL());
link_lengths = double(matlabReadLDT.linkLengths);

end
