function [] = plotDiff(nid1, cid1, run_id1, type1, nid2, cid2, run_id2, type2, startDate, endDate,...
    lidsStr, dataTypeOption, username, password)

% main plotting function
% generate plots of density/velocity for two runs and plot the difference

if isempty(str2num(lidsStr))
    lids = loadLidsByName(lidsStr);
else
    lids = lidsStr;
end

if strcmp(dataTypeOption, 'velocity')
    [links1, d1, ~, times1, link_lengths1] = readLDT(nid1, cid1, run_id1, startDate, endDate, lids, dataTypeOption, 2, type1, username, password);
    [links2, d2, ~, times2, link_lengths2] = readLDT(nid2, cid2, run_id2, startDate, endDate, lids, dataTypeOption, 2, type2, username, password);
else
    [links1, ~, d1, times1, link_lengths1] = readLDT(nid1, cid1, run_id1, startDate, endDate, lids, dataTypeOption, 2, type1, username, password);
    [links2, ~, d2, times2, link_lengths2] = readLDT(nid2, cid2, run_id2, startDate, endDate, lids, dataTypeOption, 2, type2, username, password);
end

%check that links are the same for 1 and 2
[nblinks1,~]=size(links1);
[nblinks2,~]=size(links2);
if nblinks1~=nblinks2
    error('links do not match');
end
test=(links1==links2);
if (sum(test)/nblinks1)~=1
    error('links do not match');
end

%check that times are the same for 1 and 2
[nbtimes1,~]=size(times1);
[nbtimes2,~]=size(times2);
if nbtimes1~=nbtimes2
    error('times do not match');
end
test=(times1==times2);
if (sum(test)/nbtimes1)~=1
    error('times do not match');
end

%check that link_lengths are the same for 1 and 2
[nblink_lengths1,~]=size(link_lengths1);
[nblink_lengths2,~]=size(link_lengths2);
if nblink_lengths1~=nblink_lengths2
    error('link_lengths do not match');
end
test=(link_lengths1==link_lengths2);
if (sum(test)/nblink_lengths1)~=1
    error('link_lengths do not match');
end

%reshape
[reshapedMatrix1, fineSpace1, timeValues1] = reshapeLDT(d1, times1, link_lengths1, startDate, dataTypeOption);
[reshapedMatrix2, fineSpace2, timeValues2] = reshapeLDT(d2, times2, link_lengths2, startDate, dataTypeOption);

%plot density/velocity
if strcmp(dataTypeOption, 'velocity')
    figure
    plotLinkVelocities(reshapedMatrix1, fineSpace1, timeValues1, startDate, endDate, run_id1)
    figure
    plotLinkVelocities(reshapedMatrix2, fineSpace2, timeValues2, startDate, endDate, run_id2)
else
    figure
    plotLinkDensities(reshapedMatrix1, fineSpace1, timeValues1, startDate, endDate, run_id1)
    figure
    plotLinkDensities(reshapedMatrix2, fineSpace2, timeValues2, startDate, endDate, run_id2)
end

%build the metric for difference
metricDif = d2-d1;
[reshapedMatrix, fineSpace, timeValues] = reshapeLDT(metricDif, times1, link_lengths1, startDate, dataTypeOption);

%plot the metric for difference
if strcmp(dataTypeOption, 'velocity')
    figure
    plotVelocityDiff(reshapedMatrix, fineSpace, timeValues, startDate, endDate, run_id1, run_id2)
else
    figure
    plotDensityDiff(reshapedMatrix, fineSpace, timeValues, startDate, endDate, run_id1, run_id2)
end

