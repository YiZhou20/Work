function [rs,travel_time] = plot_travel_time(routes, nid, run_id, startDate, endDate, agg_period, dt, report_dt, v_l, ... 
    links, velocities, densities, times, link_lengths, total_lids, movement, approach)

%% set up movements and approaches

if nargin < 17
    approach = {'N','S','E','W'};
    if nargin < 16
        movement = {'thru','left','right'};
    end
end

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
            travel_time(k,ind) = calculate_travel_time( ... 
        links, velocities, densities, times, link_lengths, total_lids, route_lids, dates{ind}, dates{ind+1}, dt, report_dt, v_l);
        end
        rs(k).t = travel_time(k,:);
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
