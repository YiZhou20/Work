function [] = plot3links(lid1,lid2,lid3,nid,cid,run_id, ...
    startDate, endDate, dataTypeOption, username, password)

l1 = num2str(lid1);
l2 = num2str(lid2);
l3 = num2str(lid3);

if strcmp(dataTypeOption, 'velocity')
    [~, d1, ~, ~, ~] = readLDT(nid, cid, run_id, startDate, endDate, l1, dataTypeOption, 2, 1, username, password);
    [~, d2, ~, ~, ~] = readLDT(nid, cid, run_id, startDate, endDate, l2, dataTypeOption, 2, 1, username, password);
    [~, d3, ~, ~, ~] = readLDT(nid, cid, run_id, startDate, endDate, l3, dataTypeOption, 2, 1, username, password);
else
    [~, ~, d1, ~, ~] = readLDT(nid, cid, run_id, startDate, endDate, l1, dataTypeOption, 2, 1, username, password);
    [~, ~, d2, ~, ~] = readLDT(nid, cid, run_id, startDate, endDate, l2, dataTypeOption, 2, 1, username, password);
    [~, ~, d3, ~, ~] = readLDT(nid, cid, run_id, startDate, endDate, l3, dataTypeOption, 2, 1, username, password);
end

t = startDate(4) + 1;
for i = 1:6
    if t == 12
        xticklabel{i} = '12PM';
    elseif t > 12
        xticklabel{i} = [num2str(t-12),'PM'];
    else
        xticklabel{i} = [num2str(t),'AM'];
    end
    t = t+4;
    if t >= 24
        t = t-24;
    end
end

min = startDate(5);
if startDate(6) == 30
    ind = 2*(60-min);
else
    ind = 2*(60-min)+1;
end

figure
n = length(d1);
plot(1:n,d1,'r',1:n,d2,'b',1:n,d3,'g')
set(gca,'Fontsize',24,'XLim',[0,n],'XTick',ind:480:n,'XTickLabel',xticklabel)
xlabel('Time','Fontsize',28)
legend(['link',l1],['link',l2],['link',l3],28)
if strcmp(dataTypeOption, 'velocity')
    ylabel('velocity (m/s)','Fontsize',28)
    title(['Velocities of Run',num2str(run_id),' over Adjacent Links'],'Fontsize',32,'Fontweight','bold')
else
    ylabel('density (veh/m)','Fontsize',28)
    title(['Densities of Run',num2str(run_id),' over Adjacent Links'],'Fontsize',32,'Fontweight','bold')
end