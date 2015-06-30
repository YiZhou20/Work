function fidPlots = plotEstimation(nid, cid, run_id, startDate, endDate, lidsName,...
    username, password, dataTypeOption, parentFolder, fidDT, saveDir, spaces)

addpath ../newplotting
cdDir = [saveDir, dataTypeOption,'/',parentFolder];
pageName = [cdDir,'/',parentFolder,'.html'];
pageOut = [cdDir,'/Run',num2str(run_id),'.html'];

% set up graphical webpage
% estimation run
% inline frame
fidPlots = fopen(pageOut,'a');
fprintf(fidPlots,['<html> \n\t<head> \n\t</head> \n\t<body bgcolor="white">',...
    '\n\t\t<h1>Estimation Run</h1>']);
s = generateName(startDate);
t = generateName(endDate);
fprintf(fidPlots,['\n\t\t<p>',s,' - ',t,'</p>']);
fprintf(fidPlots,'\n\t\t<table cellpadding="0" cellspacing="0" border="0">');
fprintf(fidPlots,'\n\t\t\t<tr>');

% outer page
fidUp = fopen(pageName,'a');
fprintf(fidUp,['<html> \n\t<head> \n\t</head> \n\t<body bgcolor="white">',...
    '\n\t\t<h1>Estimation Run</h1>']);
if strcmp(dataTypeOption,'velocity')
    fprintf(fidUp,'\n\t\t<h2>Velocity</h2>');
    fprintf(fidUp,['<h2><a href="../../density/',parentFolder,'/',parentFolder,'.html">Density</a></h2>']);
else
    fprintf(fidUp,['<h2><a href="../../velocity/',parentFolder,'/',parentFolder,'.html">Velocity</a></h2>']);
    fprintf(fidUp,'\n\t\t<h2>Density</h2>');
end
fprintf(fidUp,['\n\t\t<p>',s,' - ',t,'</p>']);
fprintf(fidUp,'\n\t\t<table cellpadding="0" cellspacing="0" border="0">');
fprintf(fidUp,'\n\t\t\t<tr>');

% link to upper level
fprintf(fidDT,['\n\t\t<h2><a href="',parentFolder,'/',parentFolder,'.html','">',parentFolder,'</a></h2>']);
mkdir(cdDir,'estimation');
dir = [cdDir,'/estimation/'];

dates = {};
n = 0;
while compareDates(startDate,endDate)
    n = n+1;
    dates{n} = startDate;
    startDate = updateDate(startDate);
end

if strcmp(dataTypeOption,'velocity')
    for i = 1:n-1
        startTime = dates{i};
        endTime = dates{i+1};
        plotVelocity(nid, cid, run_id, startTime, endTime, lidsName, 2, 1, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
        fprintf(fidUp,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
    for j = 1:spaces
            fprintf(fidUp,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
    end
elseif strcmp(dataTypeOption,'density')
    for i = 1:n-1
        startTime = dates{i};
        endTime = dates{i+1};
        plotDensity(nid, cid, run_id, startTime, endTime, lidsName, 2, 1, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
        fprintf(fidUp,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
    for j = 1:spaces
            fprintf(fidUp,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
    end
elseif strcmp(dataTypeOption,'velocity_sd')
    for i = 1:n-1
        startTime = dates{i};
        endTime = dates{i+1};
        plotVelocity(nid, cid, run_id, startTime, endTime, lidsName, 4, 1, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
        fprintf(fidUp,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
    for j = 1:spaces
            fprintf(fidUp,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
    end
else
    for i = 1:n-1
        startTime = dates{i};
        endTime = dates{i+1};
        plotDensity(nid, cid, run_id, startTime, endTime, lidsName, 4, 1, username, password)
        set(gca,'position',[0 0 1 1],'units','normalized')
        axis off
        set(gcf, 'PaperPosition', [0 0 30 170]/150)
        nameStr = [dir,generateName(startTime),'.png'];
        print(gcf,'-dpng',nameStr);
        fprintf(fidPlots,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
        fprintf(fidUp,['\n\t\t\t\t<td><img src="estimation/',generateName(startTime),...
            '.png" style="border-right: 1px solid black;"></td>']);
    end
    for j = 1:spaces
            fprintf(fidUp,'\n\t\t\t\t<td><img src="../../spacer.png" style="border-right: 1px solid black;"></td>');
    end
end
close all

fprintf(fidUp,'\n\t\t\t</tr> \n\t\t</table>');

% set up iframe
width = (n+spaces)*30;
if width < 800
    width = 800;
end
fprintf(fidUp,['\n\t<hr> \n\t\t<iframe seamless name="',parentFolder,'" src="Run',...
    num2str(run_id),'.html" height="250" width="',num2str(width),'"> </iframe> \n\t</hr> \n\t</body> \n</html>']);
fclose(fidUp);
