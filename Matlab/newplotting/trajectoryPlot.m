function [] = ...
    trajectoryPlot(nid, cid, run_id, startDate, endDate, lidsStr, qty_type, type, username, password)
                
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

[~, ~, data_vector, times, link_lengths] = readLDT(nid, cid, run_id, startDate, endDate, lids, 'density', qty_type, type, username, password);

dt = (times(2) - times(1))/1000;

% Convert input start date to a usable form.
startDateInDays = datenum(datestr([startDate(1), startDate(2), startDate(3), ...
    startDate(4), startDate(5), startDate(6)], 'yyyy-mm-dd HH:MM:SS'));
matlabStartDate = startDateInDays; %floor(startDateInDays*12)/12;

% Determine number of timesteps
duration = max(times) - min(times);
numTimeSteps = ((duration/1000)/dt)+1;
timeValues = zeros(numTimeSteps, 1);
for i = 1:numTimeSteps
    timeValues(i) = matlabStartDate + (dt * (i-1))/60/60/24;
end

% Convert the raw vector of velocities into a matrix by reshaping, and flip
% so it is in the correct orientation for plotting.
reshapedMatrix = flipud(rot90(reshape(data_vector, ...
    cast(numTimeSteps, 'int32'), [])));
[~, bb] = size(reshapedMatrix);
link_len_mat = repmat(link_lengths,1,bb);
veh_mat = link_len_mat .* reshapedMatrix;
veh = veh_mat;
veh(:,1) = cumsum(veh(:,1));
veh = cumsum(veh,2);
contour((flipud(cumsum(veh,1))),'LineWidth',2);
title('Trajectories for Run ID 4856 WestBound');


if west_bound
    a = 100000;
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
    b = 100001;
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


startDateInDays = datenum(datestr([startDate(1), startDate(2), startDate(3), ...
    startDate(4), startDate(5), startDate(6)], 'yyyy-mm-dd HH:MM:SS'));
endDateInDays = datenum(datestr([endDate(1), endDate(2), endDate(3), ...
    endDate(4), endDate(5), endDate(6)], 'yyyy-mm-dd HH:MM:SS'));

matlabStartDate = floor(startDateInDays*12)/12;
matlabEndDate = floor(endDateInDays*12)/12;
set(gca,'yDir', 'normal', 'FontSize', 16);

% Defines the x-axis steps by the number of days. Fewer number of days
% means higher granularity, and reverse.
numberOfDays = floor(matlabEndDate - matlabStartDate +1);
xStepForAxis = [1 2 2 2 3 3 4 6 6 6 6 12 12 12 12 12 12 12];
xStep = xStepForAxis(numberOfDays)*360;

% Defines the ticks and labels. On x axis, the ticks are purely time of
% day, i.e. 8AM 12PM 4PM etc.
x_ticks = 1:xStep:size(reshapedMatrix, 2);
x_labels = datestr(timeValues(x_ticks), 'HH:MMPM');
%y_labels = fineSpace(get(gca,'YTick'));

%set(gca,'YTickLabel', y_labels);
set(gca,'Xtick', x_ticks);
set(gca,'XTickLabel', x_labels);



end