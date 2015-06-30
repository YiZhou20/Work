function [lane_group_los, intersection_los,intersection_los_num] = level_of_service(delay, routes, ...
    nid, run_id, start_time, end_time, app_type_id)

% determine los for each lane group and the intersection as a whole

% get first and last link id for each route
first_link_str = '';
first_links = [];
last_link_str = '';
last_links = [];
for i = 1:length(routes)
    lane_group_los{1,i} = routes(i);
    rids = loadRouteLinks(routes(i));
    if ~ismember(rids(end),first_links)
        first_link_str = [first_link_str, num2str(rids(end)),','];
    end
    first_links(i) = rids(end);
    if ~ismember(rids(1),last_links)
        last_link_str = [last_link_str, num2str(rids(1)),','];
    end
    last_links(i) = rids(1);
    
end
first_link_str = first_link_str(1:end-1);
last_link_str = last_link_str(1:end-1);

% average delay per vehicle and los per lane group
[inlinks, inflows, ~, ~, ~] = readLDT(nid, 0, run_id, start_time, end_time, last_link_str, ...
    'inflow', 2, app_type_id, 'yizhou','shmilm20');

for i = 1:length(routes)
    inflow = inflows(inlinks == last_links(i));
    
    avg_delay_per_veh = sum((inflow(1:end-1))'.*delay(i,:))/sum(inflow(1:end-1));
    if avg_delay_per_veh <= 10
        lane_group_los{2,i} = 'A';
    elseif avg_delay_per_veh <= 20
        lane_group_los{2,i} = 'B';
    elseif avg_delay_per_veh <= 35
        lane_group_los{2,i} = 'C';
    elseif avg_delay_per_veh <= 55
        lane_group_los{2,i} = 'D';
    elseif avg_delay_per_veh <= 80
        lane_group_los{2,i} = 'E';
    else
        lane_group_los{2,i} = 'F';
    end
    lane_group_los{3,i} = avg_delay_per_veh;
    lane_group_delay(i) = avg_delay_per_veh;
end

% average outflow
[inlinks, ~, outflows, ~, ~] = readLDT(nid, 0, run_id, start_time, end_time, first_link_str, ...
    'outflow', 2, app_type_id, 'yizhou','shmilm20');

for i = 1:length(routes)
    outflow(i) = mean(outflows(inlinks == first_links(i)));
end

% weighed intersection delay and los
avg_delay = sum(outflow.*lane_group_delay)/sum(outflow);
intersection_los_num = avg_delay;
if avg_delay <= 10
    intersection_los = 'A';
elseif avg_delay <= 20
    intersection_los = 'B';
elseif avg_delay <= 35
    intersection_los = 'C';
elseif avg_delay <= 55
    intersection_los = 'D';
elseif avg_delay <= 80
    intersection_los = 'E';
else
    intersection_los = 'F';
end
