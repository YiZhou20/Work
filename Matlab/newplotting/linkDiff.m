function [m1] = linkDiff(linkid, n1,c1,r1,t1, n2,c2,r2,t2, startDate, endDate, dataTypeOption, username, password)

lid = num2str(linkid);

if strcmp(dataTypeOption, 'velocity')
    [~, d1, ~, ~, ~] = readLDT(n1, c1, r1, startDate, endDate, lid, dataTypeOption, 2, t1, username, password);
    [~, d2, ~, ~, ~] = readLDT(n2, c2, r2, startDate, endDate, lid, dataTypeOption, 2, t2, username, password);
else
    [~, ~, d1, ~, ~] = readLDT(n1, c1, r1, startDate, endDate, lid, dataTypeOption, 2, t1, username, password);
    [~, ~, d2, ~, ~] = readLDT(n2, c2, r2, startDate, endDate, lid, dataTypeOption, 2, t2, username, password);
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
plot(1:n,d1,'r',1:n,d2,'b')
set(gca,'Fontsize',24,'XLim',[0,n],'XTick',ind:480:n,'XTickLabel',xticklabel)
xlabel('Time','Fontsize',28)
legend(['Run',num2str(r1)],['Run',num2str(r2)],28)
if strcmp(dataTypeOption, 'velocity')
    ylabel('velocity (m/s)','Fontsize',28)
    title(['Velocity Comparison of Two Runs over link',lid],'Fontsize',32,'Fontweight','bold')
else
    ylabel('density (veh/m)','Fontsize',28)
    title(['Density Comparison of Two Runs over link',lid],'Fontsize',32,'Fontweight','bold')
end

figure
d = d1 - d2;
plot(1:n,d)
set(gca,'Fontsize',24,'XLim',[0,n],'XTick',ind:480:n,'XTickLabel',xticklabel)
xlabel('Time','Fontsize',28)
if strcmp(dataTypeOption, 'velocity')
    ylabel('Velocity Difference','Fontsize',28)
    title(['Velocity Difference between Run',num2str(r1),' and Run',num2str(r2),' over link',lid],'Fontsize',32,'Fontweight','bold')
else
    ylabel('Density Difference','Fontsize',28)
    title(['Density Difference between Run',num2str(r1),' and Run',num2str(r2),' over link',lid],'Fontsize',32,'Fontweight','bold')
end


% Metrics1 -- Root-Mean-Square
m1 = rms(d);
% Metrics2 -- Percentage-Root-Mean-Square

% Metrics3 -- Weighted-Percentage-Root-Mean-Square
