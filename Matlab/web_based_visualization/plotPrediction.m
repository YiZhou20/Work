function [] = plotPrediction(nid, cid, run_id, startDate, lidsName, ...
    username, password, dataTypeOption, parentFolder, n, fidPlots, saveDir)

addpath ../newplotting

dirName = ['prediction',num2str(run_id)];
cdDir = [saveDir, dataTypeOption,'/',parentFolder];
mkdir(cdDir,dirName);
dir = [cdDir,'/',dirName,'/'];

dates{1} = startDate;
for i = 1:n
    startDate = updateDate(startDate);
    dates{i+1} = startDate;
end

if strcmp(dataTypeOption,'velocity')
    for i = 1:n
        startTime = dates{i};
        endTime = dates{i+1};
        plotVelocity(nid, cid, run_id, startTime, endTime, lidsName, 2, 5, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="',dirName,'/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
elseif strcmp(dataTypeOption,'density')
    for i = 1:n
        startTime = dates{i};
        endTime = dates{i+1};
        plotDensity(nid, cid, run_id, startTime, endTime, lidsName, 2, 5, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="',dirName,'/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
elseif strcmp(dataTypeOption,'velocity_sd')
    for i = 1:n
        startTime = dates{i};
        endTime = dates{i+1};
        plotVelocity(nid, cid, run_id, startTime, endTime, lidsName, 4, 5, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="',dirName,'/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
else
    for i = 1:n
        startTime = dates{i};
        endTime = dates{i+1};
        plotDensity(nid, cid, run_id, startTime, endTime, lidsName, 4, 5, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="',dirName,'/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
end
close all