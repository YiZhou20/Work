function [] = plotLinkVelocities(velocityMatrix, fineSpace, timeValues, ...
    startDate, endDate, run_id, plotSD)

if nargin == 6
    plotSD = false;
end

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
cmap1 = jet(numColors);
cmap2 = cmap1(round(numColors*27/32):-1:round(numColors*15/32),:);
sstep = 1/(length(cmap2)+1);
scalefactor1 = sin((sstep:sstep:(1-sstep))*pi)';
scalefactor = (0.4*scalefactor1+0.6) * [1 1 1];
cmap = cmap2.*scalefactor;
cmap(1,:) = [0 0 0]; % speed = 0 maps to black

imagesc(velocityMatrix);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
if plotSD
    set(gca,'cLim',[0,5]);
else
    set(gca,'cLim',[0,80]);
end
set(gcf,'Colormap',cmap);

if plotSD
    title(sprintf('Velocity StdDev for Run ID %d', run_id), 'FontSize', 24);
else
    title(sprintf('Velocities for Run ID %d', run_id), 'FontSize', 24);
end
xlabel('Time', 'FontSize', 20);
ylabel('Position (miles)', 'FontSize', 20);
colorbar

% The image by default plots increasing y-values reading down, so make it
% normal direction.
set(gca,'yDir', 'normal', 'FontSize', 16);

% Defines the x-axis steps by the number of days. Fewer number of days
% means higher granularity, and reverse.
numberOfDays = floor(matlabEndDate - matlabStartDate +1);
xStepForAxis = [1 2 2 2 3 3 4 6 6 6 6 12 12 12 12 12 12 12];
xStep = xStepForAxis(numberOfDays)*360;

% Defines the ticks and labels. On x axis, the ticks are purely time of
% day, i.e. 8AM 12PM 4PM etc.
x_ticks = 1:xStep:size(velocityMatrix,2);
x_labels = datestr(timeValues(x_ticks), 'HH:MMPM');
y_labels = fineSpace(get(gca,'YTick'));

set(gca,'YTickLabel', y_labels);
set(gca,'Xtick', x_ticks);
set(gca,'XTickLabel', x_labels);

end