function [rs,vht,vmt,total_delay,travel_time,delay_from_travel_time] = ...
    metrics_vis(routes, nid, run_id, startDate, endDate, agg_period, dt, report_dt, v_l, ... 
    links, velocities, densities, times, link_lengths, total_lids, movement, approach)
% routes: matrix of route ids up to size 3*4
    % rows as movement types, e.g. through/left
    % columns as approach direction, e.g. north/south
    % put in 0 to skip
% agg_period: aggregation period of metrics, in minutes between 0 and 60
% v_l: a number, freeflow speed in mph, dummy variable, not in use
% dt: in seconds
% report_dt: reporting interval in seconds
% movement: cell array up to size 1*3 that specifies rows of routes
    % optional, DEFAULT {'thru','left','right'}
% approach: cell array up to size 1*4 that specifies columns of routes
    % optional, DEFAULT {'N','S','E','W'}

% TODO: check that v_l satisfies required formats
%% set up movements and approaches

if nargin < 17
    approach = {'N','S','E','W'};
    if nargin < 16
        movement = {'thru','left','right'};
    end
end

% load route data
%[links, velocities, densities, times, link_lengths, total_lids, start_date, end_date] = ... 
%    collectRouteData(routes, nid, run_id, startDate, endDate, app_type_id);

%% get aggregation dates
if agg_period < 1
    agg_period_s = agg_period * 60;
end

startTime = min(times);
endTime = max(times);

if agg_period < 1
    startDate_next = advance_time_sec(startDate, agg_period_s);
else
    startDate_next = advance_time(startDate, agg_period);
end

while convertTimeToMilliseconds(startDate_next) <= startTime
    startDate = startDate_next;
    if agg_period < 1
        startDate_next = advance_time_sec(startDate, agg_period_s);
    else
        startDate_next = advance_time(startDate, agg_period);
    end
end

if convertTimeToMilliseconds(startDate) > startTime
    dates{1} = startDate;
else
    dates{1} = convertMillisecondsToTime(startTime);
end

n_period = 2;

while convertTimeToMilliseconds(startDate_next) < convertTimeToMilliseconds(endDate) && ... 
        convertTimeToMilliseconds(startDate_next) < endTime
    dates{n_period} = startDate_next;
    if agg_period < 1
        startDate_next = advance_time_sec(startDate_next, agg_period_s);
    else
        startDate_next = advance_time(startDate_next, agg_period);
    end
    n_period = n_period + 1;
end

if convertTimeToMilliseconds(endDate) < endTime
    dates{n_period} = endDate;
else
    dates{n_period} = convertMillisecondsToTime(endTime);
end

%% calculate metrics for each route over periods

[m,n] = size(routes);
k = 1;
legend_tags = {};

for i = 1:m
    for j = 1:n
        % set up plotting referrences
        rid = routes(i,j);
        if rid == 0
            continue
        end
        rs(k).route_id = rid;
        rs(k).type = i;
        rs(k).direction = j;
        rs(k).description = [approach{j},' ',movement{i}];
        % prepare legend
        legend_tags{k} = [approach{j},' ',movement{i}];
        % get lids for this route
        route_lids = loadRouteLinks(rid);
        % run metrics code
        for ind = 1:n_period-1
            [vht(k,ind), vmt(k,ind), total_delay(k,ind), travel_time(k,ind), delay_from_travel_time(k,ind)] = metrics( ... 
        links, velocities, densities, times, link_lengths, total_lids, route_lids, dates{ind}, dates{ind+1}, dt, report_dt, v_l);
        end
        rs(k).vht = vht(k,:);
        rs(k).vmt = vmt(k,:);
        rs(k).td = total_delay(k,:);
        rs(k).t = travel_time(k,:);
        rs(k).dl = delay_from_travel_time(k,:);
        k = k+1;
    end
end

%% plots

% constants for colors and linestyles
colors = {'r','g','b','y'};
lines = {'-',':','-.'};
markers = {'x','o','s'};

% x axis
x_vals = [];
for x_val = 1:n_period-1
    x_vals = [x_vals, datenum(dates{x_val})];
end

% vht
figure
hold on
for r = 1:k-1
    c_lst = [lines{rs(r).type}, colors{rs(r).direction}, markers{rs(r).type}];
    vhts = vht(r,:);
    plot(x_vals,vhts,c_lst, 'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',28)
    ylabel('vht (veh*hr)','fontsize',28)
    title(['Vehicle Hours Traveled for Network ', num2str(nid), ' Run ', num2str(run_id)],'fontsize',28)
    legend(legend_tags)
    set(gca,'fontsize',20)
hold off

% vmt
figure
hold on
for r = 1:k-1
    c_lst = [lines{rs(r).type}, colors{rs(r).direction}, markers{rs(r).type}];
    vmts = vmt(r,:);
    plot(x_vals,vmts,c_lst, 'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',28)
    ylabel('vmt (veh*mile)','fontsize',28)
    title(['Vehicle Miles Traveled for Network ', num2str(nid), ' Run ', num2str(run_id)],'fontsize',28)
    legend(legend_tags)
    set(gca,'fontsize',20)
hold off

% total delay
figure
hold on
for r = 1:k-1
    c_lst = [lines{rs(r).type}, colors{rs(r).direction}, markers{rs(r).type}];
    tds = total_delay(r,:);
    plot(x_vals,tds,c_lst, 'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',28)
    ylabel('total delay (veh*hr)','fontsize',28)
    title(['Total Delay for Network ', num2str(nid), ' Run ', num2str(run_id)],'fontsize',28)
    legend(legend_tags)
    set(gca,'fontsize',20)
hold off

% travel time
figure
hold on
for r = 1:k-1
    c_lst = [lines{rs(r).type}, colors{rs(r).direction}, markers{rs(r).type}];
    tts = travel_time(r,:);
    plot(x_vals,tts,c_lst, 'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',28)
    ylabel('travel time (sec)','fontsize',28)
    title(['Travel Time for Network ', num2str(nid), ' Run ', num2str(run_id)],'fontsize',28)
    legend(legend_tags)
    set(gca,'fontsize',20)
hold off

% delay from travel time
figure
hold on
for r = 1:k-1
    c_lst = [lines{rs(r).type}, colors{rs(r).direction}, markers{rs(r).type}];
    delays = delay_from_travel_time(r,:);
    plot(x_vals,delays,c_lst, 'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',28)
    ylabel('Delay (sec)','fontsize',28)
    title(['Delay from Experienced Travel Time for Network ', num2str(nid), ' Run ', num2str(run_id)],'fontsize',28)
    legend(legend_tags)
    set(gca,'fontsize',20)
hold off
