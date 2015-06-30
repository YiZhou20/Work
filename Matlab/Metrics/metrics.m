function [vht, vmt, delay, travel_time, delay_from_travel_time] = metrics( ... 
    links, velocities, densities, times, link_lengths, lids, route, startDate, endDate, dt, report_dt, v_l)

% aggregated metrics of a route overtime
% v_l: freeflow speeds in mph, a number OR vector same length as route
% speed limits calculated from link lengths, v_l not in use
% dt: time step in seconds
% report_dt: reporting interval in seconds

n = length(v_l);
if ~(n == 1 || n == length(route))
    error('freeflow speed can only be one number or a vector the same length as route');
end
if n == 1
    v_l = ones(1,length(route)) * v_l;
end

% constants
Convert2MPH = 2.23693629;

addpath ../pems_data_visualization
startTime = convertTimeToMilliseconds(startDate);
endTime = convertTimeToMilliseconds(endDate);

% time range error
if startTime < min(times)
    error('start date not in fetched data, use later dates');
end

end_ts = max(times);
if endTime > end_ts
    error('end date not in fetched date, use earlier dates');
end

travel_time_ts = startTime;
travel_time = 0;
freeflow_time = 0;
vht = 0;
vmt = 0;
delay_l = 0;


% travel time
for i = 1:length(route)
    lid = route(i);

    % if travel time exceeds available data
    if travel_time_ts > end_ts
        travel_time = Inf;
        break
    end    
    [velocity_t, ~] = get_link_data(links, velocities, densities, times, lid, travel_time_ts);
    link_length = link_lengths(lids == lid);
    t_l = link_travel_time(links, velocities, times, lid, travel_time_ts, dt, report_dt, link_length, velocity_t, end_ts);
    % time out of boundary
    if isinf(t_l)
        travel_time = Inf;
        break
    end
    % rounding to nearest multiple of dt
    travel_time_ts = travel_time_ts + round(t_l/report_dt)*report_dt*1000;
    travel_time = travel_time + t_l;
    freeflow_time = freeflow_time + link_length / (link_length/dt);
end
    
% other metrics
for i = 1:length(route)
    lid = route(i);
    ts = startTime;
    vht_l = 0;
    vmt_l = 0;
    
    while ts <= endTime
        [velocity, density] = get_link_data(links, velocities, densities, times, lid, ts);
        vht_l = vht_l + link_vht(density, link_length, report_dt);
        vmt_l = vmt_l + link_vmt(density, velocity, link_length, report_dt);
        ts = ts + report_dt*1000;
    end
    
    vht = vht + vht_l;
    vmt = vmt + vmt_l;
    delay_l = delay_l + vmt_l/(link_length/dt*Convert2MPH);
    
end

if isinf(travel_time)
    delay_from_travel_time = Inf;
else
    delay_from_travel_time = travel_time - freeflow_time;
end

delay = vht - delay_l;



