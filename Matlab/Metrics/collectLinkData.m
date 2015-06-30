function [links, velocities, densities, times, link_lengths, lids, start_date, end_date] = ... 
    collectLinkData(nid, run_id, startDate, endDate, app_type_id)

import edu.berkeley.path.pemsviz.*;
global gb_conn
pemsreader = PemsReader(gb_conn);

[ps, queryString] = loadQueryForLids();

lidstr = '';
lids = [];

success = pemsreader.createLidQuery(ps, queryString, num2str(nid));
pemsreader.executePemsCountQuery();
while pemsreader.hasNextRow()
    lid = pemsreader.getRowResult('id');
    lids = [lids, lid];
    lidstr = [lidstr, num2str(lid), ','];
end

lidstr = lidstr(1:end-1);

[links, velocities, ~, times, link_lengths] = ...
    readLDT(nid, 0, run_id, startDate, endDate, lidstr, 'velocity', 2, app_type_id, 'yizhou', 'shmilm20');

[~, ~, densities, ~, ~] = readLDT(nid, 0, run_id, startDate, endDate, lidstr, 'density', 2, app_type_id, 'yizhou', 'shmilm20');

if max(times) == convertTimeToMilliseconds(endDate)
    end_date = endDate;
else
    end_date = convertMillisecondsToTime(max(times));
end

if min(times) == convertTimeToMilliseconds(startDate)
    start_date = startDate;
else
    start_date = convertMillisecondsToTime(min(times));
end

