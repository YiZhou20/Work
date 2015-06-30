function [] = plotVelocityDiff(difMatrix, fineSpace, timeValues, ...
    startDate, endDate, run_id1, run_id2)

startDateInDays = datenum(datestr([startDate(1), startDate(2), startDate(3), ...
    startDate(4), startDate(5), startDate(6)], 'yyyy-mm-dd HH:MM:SS'));
endDateInDays = datenum(datestr([endDate(1), endDate(2), endDate(3), ...
    endDate(4), endDate(5), endDate(6)], 'yyyy-mm-dd HH:MM:SS'));

matlabStartDate = floor(startDateInDays*12)/12;
matlabEndDate = floor(endDateInDays*12)/12;

% --------
% PLOTTING
% --------

% Define the colormap. Green = high velocities, Red = low velocities,
% Black = no velocity.
numColors = 256;
cmap = jet(numColors);
%cmap1 = jet(numColors);
%cmap2 = cmap1(round(numColors*27/32):-1:round(numColors*15/32),:);
%sstep = 1/(length(cmap2)+1);
%scalefactor1 = sin((sstep:sstep:(1-sstep))*pi)';
%scalefactor = (0.4*scalefactor1+0.6) * [1 1 1];
%cmap = cmap2.*scalefactor;

imagesc(difMatrix);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gca,'cLim',[-30,30]);
set(gcf,'Colormap',cmap);

title(['Velocity Difference between run', num2str(run_id1), ' and run', num2str(run_id2)], 'FontSize', 20);
xlabel('Time', 'FontSize', 18);
ylabel('Position (miles)', 'FontSize', 18);
colorbar

% The image by default plots increasing y-values reading down, so make it
% normal direction.
set(gca,'yDir', 'normal', 'FontSize', 12);

% Defines the x-axis steps by the number of days. Fewer number of days
% means higher granularity, and reverse.
numberOfDays = floor(matlabEndDate - matlabStartDate +1);
xStepForAxis = [1 2 2 2 3 3 4 6 6 6 6 12 12 12 12 12 12 12];
xStep = xStepForAxis(numberOfDays)*120;

% Defines the ticks and labels. On x axis, the ticks are purely time of
% day, i.e. 8AM 12PM 4PM etc.
x_ticks = 1:xStep:size(difMatrix,2);
x_labels = datestr(timeValues(x_ticks), 'HHPM');
y_labels = fineSpace(get(gca,'YTick'));

set(gca,'YTickLabel', y_labels);
set(gca,'Xtick', x_ticks);
set(gca,'XTickLabel', x_labels);

end