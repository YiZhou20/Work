function [links, velocities, densities, times, link_lengths, total_lids, start_date, end_date] = ... 
    collectRouteData(rids, nid, run_id, startDate, endDate, app_type_id)

% reads link data total for certain routes for a run

total_lids = [];
lidstr = '';

for i = 1:length(rids)
    lids = loadRouteLinks(rids(i));
    for j = 1:length(lids)
        if ~ismember(lids(j),total_lids)
            total_lids = [total_lids, lids(j)];
            lidstr = [lidstr, num2str(lids(j)),','];
        end
    end
end

lidstr = lidstr(1:end-1);

[links, velocities, ~, times, link_lengths] = ...
    readLDT(nid, 0, run_id, startDate, endDate, lidstr, 'velocity', 2, app_type_id, 'yizhou', 'shmilm20');

[~, ~, densities, ~, ~] = readLDT(nid, 0, run_id, startDate, endDate, lidstr, 'density', 2, app_type_id, 'yizhou', 'shmilm20');

save('data.mat','links','velocities','densities','times','link_lengths','total_lids');

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