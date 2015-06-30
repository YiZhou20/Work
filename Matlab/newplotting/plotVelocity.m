function [] = plotVelocity(nid, cid, run_id, startDate, endDate, lidsStr, qty_type, type, username, password)

% Velocity plot of a single run

west_bound = 0;
east_bound = 0;

if lidsStr == 5
    west_bound = 1;
elseif lidsStr == 6
    east_bound = 1;
end

% rid or string
if isnumeric(lidsStr)
    addpath ../pems_data_visualization
    addpath ../Metrics
    route_lids = loadRouteLinks(lidsStr);
    lidsStr = '';
    
    for i = 1:length(route_lids)
        lidsStr = [lidsStr, num2str(route_lids(i)),','];
    end
    lidsStr = lidsStr(1:end-1);
end

if isempty(str2num(lidsStr))
    lids = loadLidsByName(lidsStr);
else
    lids = lidsStr;
end

[~, v, ~, times, link_lengths] = readLDT(nid, cid, run_id, startDate, endDate, lids, 'velocity', qty_type, type, username, password);
[reshapedMatrix, fineSpace, timeValues] = reshapeLDT(v, times, link_lengths, startDate, 'velocity');
if qty_type == 4
    plotSD = true;
else
    plotSD = false;
end
figure
plotLinkVelocities(reshapedMatrix, fineSpace, timeValues, startDate, endDate, run_id, plotSD)

if west_bound
    limits = get(gca,'YLim');
    y_length = limits(2) - limits(1);
    total_route_length = sum(link_lengths);
    cross_streets = [3 12 17 25 33 44 53 65 72 99 132 175];
    cross_street_pos = [];
    cumulated_route_length = 0;
    for i = 1:175
        cumulated_route_length = cumulated_route_length+link_lengths(i);
        if ismember(i,cross_streets)
            cross_street_pos = [cross_street_pos cumulated_route_length];
        end
    end
    cross_street_pos = cross_street_pos/total_route_length*y_length;
    set(gca,'YTick',cross_street_pos)
    set(gca,'YTickLabel',{'210W','210E','5th','Gateway','2nd','1st','Santa Anita', ...
        'Santa Clara','Huntington and Colorado', 'Colorado Blvd and Pl', 'Baldwin', 'Michillinda'});
    set(gca,'fontsize',16)
elseif east_bound
    limits = get(gca,'YLim');
    y_length = limits(2) - limits(1);
    total_route_length = sum(link_lengths);
    cross_streets = [7 49 80 107 113 125 134 145 152 159 165 175];
    cross_street_pos = [];
    cumulated_route_length = 0;
    for i = 1:175
        cumulated_route_length = cumulated_route_length+link_lengths(i);
        if ismember(i,cross_streets)
            cross_street_pos = [cross_street_pos cumulated_route_length];
        end
    end
    cross_street_pos = cross_street_pos/total_route_length*y_length;
    set(gca,'YTick',cross_street_pos)
    set(gca,'YTickLabel',{'Michillinda', 'Baldwin', 'Colorado Blvd and Pl', 'Huntington and Colorado', 'Santa Clara' ...
        'Santa Anita', '1st', '2nd', 'Gateway', '5th', '210E', '210W'});
    set(gca,'fontsize',16)
end
end