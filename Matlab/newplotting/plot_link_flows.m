function rs = plot_link_flows(link_ids, nid, run_id, app_type_id, start_time, end_time, data_option)

% plot the flow profile of specified links
% link_ids: link ids of interest in a vector
% app_type_id: 1 for estimation, 5 for prediction
% start_time, end_time: [YYYY MM DD HH MI SS]
% data_option: optional, 'outflow'/'inflow', DEFAULT: 'outflow'

if nargin == 6
    data_option = 'outflow';
end

% make lid string
lidsStr = '';
for i = 1:length(link_ids)
    legends{i} = num2str(link_ids(i));
    lidsStr = [lidsStr, num2str(link_ids(i)), ','];
end

lidsStr = lidsStr(1:end-1);

% fetch data
if strcmp(data_option, 'outflow')
    [links, ~, flows, times, ~] = readLDT(nid, 0, run_id, start_time, end_time, lidsStr, ...
        data_option, 2, app_type_id, 'yizhou','shmilm20');
else
    [links, flows, ~, times, ~] = readLDT(nid, 0, run_id, start_time, end_time, lidsStr, ...
        data_option, 2, app_type_id, 'yizhou','shmilm20');
end

timeseries = times(links == link_ids(1));

% reshape
reshaped_flow = reshape(flows, [], length(link_ids));

% record
for i = 1:length(link_ids)
    rs(i).id = link_ids(i);
    rs(i).flow = reshaped_flow(:,i)';
end

% plot
colors = {'r','g','b','m','c','k'};
% time label for x axis
addpath ../Metrics
times = [];
for i = 1:length(timeseries)
    times(i) = datenum(convertMillisecondsToTime(timeseries(i)));
end

figure
hold on
for r = 1:length(link_ids)
    link_flow = rs(r).flow * 3600;
    plot(times,link_flow,colors{r},'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',24)
    ylabel([data_option,' (veh/hr)'],'fontsize',24)
    title([data_option, ' at selected links for network ', num2str(nid), ' run ', num2str(run_id)],'fontsize',28)
    legend(legends)
    set(gca,'fontsize',16)
hold off

