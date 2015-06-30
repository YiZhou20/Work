function rs = plot_intersection_flow_by_link(link_matrix, nid, run_id, app_type_id, start_time, end_time, name)

% plot the inflows and outflows at an intersection with specified links

% IMPORTANT
% put link ids at intersection in the following order
% put 0 if link does not exist
% [EL ET ER ED; WL WT WR WD; SL ST SR SD; NL NT NR ND]
% E,W,S,N: approaches -- east, west, south, north
% L,T,R,D: movement -- left, through, right, output downstream

% name -- intersection name, OPTIONAL
if nargin == 6
    name = 'Intersection';
end

legend_tags = {};
k = 1;
approaches = {'East','West','South','North'};
movements = {'Left','Through','Right'};

%% get input link string and output link string
inlinkstr = '';
outlinkstr = '';
in_links = [];
out_links = [];
for i = 1:4
    for j = 1:4
        lid = link_matrix(i,j);
        if lid ~= 0
            if j == 4               % output links
                rs(k).link_id = lid;
                rs(k).approach = i;
                rs(k).movement = 4;
                out_links = [out_links, lid];
                outlinkstr = [outlinkstr, num2str(lid),','];
                legend_tags{k} = [approaches{i}, ' Downstream'];
            else
                rs(k).link_id = lid;
                rs(k).approach = i;
                rs(k).movement = j;
                in_links = [in_links, lid];
                inlinkstr = [inlinkstr, num2str(lid),','];
                legend_tags{k} = [approaches{i}, ' ', movements{j}];
            end
            k = k+1;
        end
    end
end

%% get outflows of input links
inlinkstr = inlinkstr(1:end-1);

[inlinks, ~, outflows, times, ~] = readLDT(nid, 0, run_id, start_time, end_time, inlinkstr, ...
    'outflow', 2, app_type_id, 'yizhou','shmilm20');

timeseries = times(inlinks == in_links(1));

for i = 1:length(in_links)
    for j = 1:k-1
        if rs(j).link_id == in_links(i)
            rs(j).flow = outflows(inlinks == in_links(i));
        end
    end
end

%% get inflows of output links
outlinkstr = outlinkstr(1:end-1);

[outlinks, inflows, ~, ~, ~] = readLDT(nid, 0, run_id, start_time, end_time, outlinkstr, ...
    'inflow', 2, app_type_id, 'yizhou','shmilm20');

for i = 1:length(out_links)
    for j = 1:k-1
        if rs(j).link_id == out_links(i)
            rs(j).flow = inflows(outlinks == out_links(i));
        end
    end
end

%% plot

% constants for colors and linestyles
colors = {'r','g','b','m'};
lines = {'-',':','--','-.'};

% time label for x axis
addpath ../Metrics
times = [];
for i = 1:length(timeseries)
    times(i) = datenum(convertMillisecondsToTime(timeseries(i)));
end

figure
hold on
for r = 1:k-1
    c_lst = [lines{rs(r).movement}, colors{rs(r).approach}];
    flows = rs(r).flow;
    plot(times,flows*3600,c_lst, 'linewidth', 2);
end
    datetick('x')
    xlabel('time','fontsize',24)
    ylabel('flows (veh/hr)','fontsize',24)
    title(['Flows at ', name, ' for Network ', num2str(nid), ' Run ', num2str(run_id)],'fontsize',28)
    legend(legend_tags)
hold off



