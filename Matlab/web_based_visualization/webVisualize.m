function [] = webVisualize(erun_id, startDate, endDate, username, password, lidsName, saveDir, n)

import java.lang.*;
import edu.berkeley.path.readldt.*;

global gb_conn

if nargin == 7
    n = 4;
end

infoWrapper = newInfoWrapper;
%setEnvironment;
%setImport;

%Monitor.set_db_env('dev-local');
%Monitor.set_prog_name('ldt_webviz');

%runinfowrapper = RunInfoWrapper(username, password);
infoWrapper.setConnection(gb_conn);

%%%%%%%%%%
% get nid, cid, prediction run ids go HERE
% Create queries and prepared statements for each different type of query
% we need:
[psRunInfo, queryRunInfo] = queryForRunInformation();
[psPredictionRuns, queryPredictionRuns] = queryForPredictionRunIDs();
[psStartTime, queryStartTime] = queryPredictionStartTime();

nid = 0;
cid = 0;

success = infoWrapper.createQuery(psRunInfo, queryRunInfo, num2str(erun_id));
if success
    infoWrapper.executeQuery(psRunInfo);
    if infoWrapper.hasNextRow(psRunInfo)
        nid = infoWrapper.getIntRowResult(psRunInfo, 'network_id');
        cid = infoWrapper.getIntRowResult(psRunInfo, 'config_id');
    end
end

prun_ids_raw = [];

success = infoWrapper.createQuery(...
    psPredictionRuns, queryPredictionRuns, num2str(erun_id));
if success
    infoWrapper.executeQuery(psPredictionRuns);
    while infoWrapper.hasNextRow(psPredictionRuns)
        prun_ids_raw = [prun_ids_raw; ...
            infoWrapper.getIntRowResult(psPredictionRuns, 'pred_app_run_id')];
    end
end

prun_ids = [];
startTimes = {};

success = infoWrapper.createQuery(psStartTime, queryStartTime, num2str(erun_id));
if success
    infoWrapper.executeQuery(psStartTime);
    if infoWrapper.hasNextRow(psStartTime)
        estimationStartTime = [...
            infoWrapper.getIntRowResult(psStartTime, 'year'),...
            infoWrapper.getIntRowResult(psStartTime, 'month'),...
            infoWrapper.getIntRowResult(psStartTime, 'day'),...
            infoWrapper.getIntRowResult(psStartTime, 'hour'),...
            infoWrapper.getIntRowResult(psStartTime, 'minute'),...
            infoWrapper.getIntRowResult(psStartTime, 'second')];
    end
end

predictionStartTime = estimationStartTime;

for i = 1:length(prun_ids_raw)
    predictionStartTime = updateDate(predictionStartTime);
    if compareDates(startDate,predictionStartTime)
        if compareDates(predictionStartTime,endDate)
            prun_ids = [prun_ids, prun_ids_raw(i)];
            startTimes{end+1} = predictionStartTime;
        else
            break;
        end
    end
end

%save('varg','nid','cid','erun_id','startDate','saveDir',...
%    'endDate','lidsName','username','password','prun_ids','startTimes','n');
%clear java;
%clear all;
%load('varg');

%fid = fopen('Estimation_Prediction_Results.html','a');
%fprintf(fid,['<html> \n\t<head> \n\t</head> \n\t<body bgcolor="white">',...
%    '\n\t\t<h1>Data Type Options</h1>']);

MonthDay = [num2str(startDate(2)),'-',num2str(startDate(3))];
parentFolder = ['Run', num2str(erun_id),'_',MonthDay,'_',generateName(startDate),'-',generateName(endDate)];

% possible plotting types
dataType = {'velocity', 'density'};

for i = 1:length(dataType)
    dataTypeOption = dataType{i};
    mkdir([saveDir,dataTypeOption],parentFolder);
    htmlName = [saveDir,dataTypeOption,'/',dataTypeOption,'.html'];
    fidDT = fopen(htmlName,'a');
%    fprintf(fid,['\n\t\t<a href="',htmlName,'">',dataTypeOption,'</a>']);
%    fprintf(fidDT,['<html> \n\t<head> \n\t</head> \n\t<body bgcolor="white">',...
%    '\n\t\t<h1>',dataTypeOption,'</h1>']);
    
    % plot the estimation run
    fidPlots = plotEstimation(nid, cid, erun_id, startDate, endDate, lidsName,...
        username, password, dataTypeOption, parentFolder, fidDT, saveDir, n);
    for sp = 1:n
        fprintf(fidPlots,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
    end
    fprintf(fidPlots,'\n\t\t\t</tr>');
    fprintf(fidPlots,'\n\t\t</table>');
    fprintf(fidPlots,'\n\t\t<h1>Prediction Runs</h1>');
    
    % plot the prediction runs
    l = length(prun_ids);
    for j = 1:l
        prun_id = prun_ids(j);
        startTime = startTimes{j};
        
        % set up
        s = generateName(startTime);
        endT = startTime;
        for t = 1:n
            endT = updateDate(endT);
        end
        e = generateName(endT);
        fprintf(fidPlots,['\n\t\t<p>',s,' - ',e,'</p>']);
        fprintf(fidPlots,'\n\t\t<table cellpadding="0" cellspacing="0" border="0">');
        fprintf(fidPlots,'\n\t\t\t<tr>');
        
        % spacer before
        if startTimes{1}(5) ~= startDate(5)
            fprintf(fidPlots,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
        end
        for sp = 1:j-1
            fprintf(fidPlots,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
        end
        
        % plot
        plotPrediction(nid, cid, prun_id, startTime, lidsName,...
            username, password, dataTypeOption, parentFolder, n, fidPlots, saveDir);
        
        % spacer after
        for sp = 1:l-j
            fprintf(fidPlots,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
        end
        fprintf(fidPlots,'\n\t\t\t</tr>');
        fprintf(fidPlots,'\n\t\t</table>');
        %save('index','i','j','l','dataTypeOption','fidPlots','parentFolder','dataType');
        %clear java;
        %clear all;
        %java.lang.System.gc();
        %load('index');
        %load('varg');
    end
    fprintf(fidPlots,'\n\t</body>');
    fprintf(fidPlots,'\n</html>');
    fclose('all');
end
