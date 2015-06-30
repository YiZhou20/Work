function [reshapedMatrix, fineSpace, timeValues, interp_lane, idx] = ...
    reshapeLDT(data_vector, times, link_lengths, startDate, dataTypeOption, num_lanes)
% Converts the raw output of LDT into a matrix usable for easy plotting.
%
% data_vector is the vector of relevant data obtained from readLDT, either
% velocities or densities.
% dataTypeOption is either velocity or density, used for determining
% whether or not to convert the data_vector to MPH.
% Each output corresponds to an input of the plotting functions.

if nargin == 5
    num_lanes = ones(1,length(link_lengths));
end

% Constants
Convert2Miles = 0.000621371192;
dt = (times(2) - times(1))/1000;
Convert2MPH = NaN;
Convert2VPH = NaN;
if strcmp(dataTypeOption, 'velocity')
    Convert2MPH = 2.23693629;
end
if strcmp(dataTypeOption, 'outflow')
    Convert2VPH = 3600;
end

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
if ~isnan(Convert2MPH)
    reshapedMatrix = reshapedMatrix * Convert2MPH;
elseif ~isnan(Convert2VPH)
    reshapedMatrix = reshapedMatrix * Convert2VPH;
else
    reshapedMatrix = reshapedMatrix * 1609.34; % to vehicles per mile
end

% Convert to flow/density per lane
lane_mat = repmat(num_lanes',1,size(reshapedMatrix,2));
reshapedMatrix = reshapedMatrix ./ lane_mat;

% Convert link lengths to miles
linkLengthsMiles = link_lengths.*Convert2Miles;

% Determine cell positions for plotting
routeShift = [[0; linkLengthsMiles], [linkLengthsMiles; 0]];
midCellPosition = cumsum(mean(routeShift,2));
midCellPosition = midCellPosition(1:(end-1));

[coarseTime, courseSpace] = meshgrid(timeValues, midCellPosition);
fineSpace = min(midCellPosition):0.01:max(midCellPosition);

reshapedMatrix = interp2(coarseTime, courseSpace, reshapedMatrix, ...
    timeValues, fineSpace, 'nearest');
interp_lane = interp1(midCellPosition,num_lanes,fineSpace,'nearest');
k = 1;
idx(k) = 1;
for i = 2:length(fineSpace)
    if interp_lane(i) ~= interp_lane(i-1)
        k = k+1;
        idx(k) = i;
    end
end


end