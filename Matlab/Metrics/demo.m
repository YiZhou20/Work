% fetch data
[links, velocities, densities, times, link_lengths, total_lids, start_date, end_date] = collectRouteData([8 9 10 11 12 13 14 15], 1138, 4836, [2014 02 03 16 30 00], [2014 02 03 17 00 00], 5);

% generate metrics and plots
[rs,vht,vmt,total_delay,travel_time,delay_from_travel_time] = metrics_vis([8,10,12,14;9,11,13,15], 1138, 4836, [2014 02 03 16 30 00], [2014 02 03 17 00 00], 0.5, 2, 30, 38.028, links, velocities, densities, times, link_lengths, total_lids);