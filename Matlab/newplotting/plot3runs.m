function [] = plot3runs(linkid,n1,c1,r1,n2,c2,r2,n3,c3,r3, startDate,endDate, dataTypeOption, username,password)

lid = num2str(linkid);

if strcmp(dataTypeOption, 'velocity')
    [~, d1, ~, ~, ~] = readLDT(n1, c1, r1, startDate, endDate, lid, dataTypeOption, 2, 1, username, password);
    [~, d2, ~, ~, ~] = readLDT(n2, c2, r2, startDate, endDate, lid, dataTypeOption, 2, 1, username, password);
    [~, d3, ~, ~, ~] = readLDT(n3, c3, r3, startDate, endDate, lid, dataTypeOption, 2, 1, username, password);
else
    [~, ~, d1, ~, ~] = readLDT(n1, c1, r1, startDate, endDate, lid, dataTypeOption, 2, 1, username, password);
    [~, ~, d2, ~, ~] = readLDT(n2, c2, r2, startDate, endDate, lid, dataTypeOption, 2, 1, username, password);
    [~, ~, d3, ~, ~] = readLDT(n3, c3, r3, startDate, endDate, lid, dataTypeOption, 2, 1, username, password);
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
legend(['Run',num2str(r1),'-SimpleAverage'],['Run',num2str(r2),'-Estimate w Sensor'],['Run',num2str(r3),'-Estimate wo Sensor'],28)

if strcmp(dataTypeOption, 'velocity')
    ylabel('velocity (m/s)','Fontsize',28)
    title(['Velocity Comparison over link',lid],'Fontsize',32,'Fontweight','bold')
else
    ylabel('density (veh/m)','Fontsize',28)
    title(['Density Comparison over link',lid],'Fontsize',32,'Fontweight','bold')
end