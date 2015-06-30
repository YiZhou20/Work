**********IMPORTANT*************
After the changes made by Luis on 12/18/2013, you need to run the following before you run any function

run('setEnvironment.m')
run('setImport.m')
createConnection(your_username_in_single_quote,your_password_in_single_quote,'ccoradb.path.berkeley.edu')

********************************


--linkDiff.m------

Plot results of two runs and their difference over a single link.

linkDiff(linkid, n1,c1,r1,t1, n2,c2,r2,t2, startDate, endDate, dataTypeOption, username, password)

linkid - id of the link to be plotted
n1,c1,r1,t1 - network id, config id, run id, type(estimation = 1; prediction = 5) of one run
n2,c2,r2,t2 - network id, config id, run id, type of another run
startDate,endDate - time range of the plot, in the form of [YYYY MM DD HH MM SS], vector of length 6
dataTypeOption - string, 'density' or 'velocity', type of data to be plotted
username,password - strings, username and password to connect to the database

Sample
linkDiff(195, 649,140,737,1, 692,139,932,1, [2013 07 17 00 00 00],[2013 07 17 20 00 00],'density','username','password')



--plotDiff.m------

Plot the difference between two runs as well as plot results for each run.

plotDiff(nid1,cid1,run_id1,type1, nid2,cid2,run_id2,type2, startDate, endDate, lidsStr, dataTypeOption, username, password)

nid1,cid1,run_id1,type1 - network id, config id, run id, type(estimation = 1; prediction = 5) of one run
nid2,cid2,run_id2,type2 - network id, config id, run id, type of another run
startDate,endDate - time range of the plot, in the form of [YYYY MM DD HH MM SS], vector of length 6
lidsStr - string, of link ids or of lidsNames, check file listOfLinkIDsNames.m for valid lidsNames
dataTypeOption - string, 'density' or 'velocity', type of data to be plotted
username,password - strings, username and password to connect to the database

Sample
plotDiff(692,139,932,1,693,139,930,1, [2013 07 17 00 00 00],[2013 07 17 20 00 00],'ORAlidsI15SB-MainlineOnly','density','username','password')



--plotDensity.m------

Plot density or density stddev of one run

plotDensity(nid, cid, run_id, startDate, endDate, lidsStr, qty_type, type, username, password)

nid,cid,run_id - network id, config id, run id of the run to be plotted
startDate,endDate - time range of the plot, in the form of [YYYY MM DD HH MM SS], vector of length 6
lidsStr - string, of link ids or of lidsNames, check file listOfLinkIDsNames.m for valid lidsNames
qty_type - 2 or 4, 2 for density mean, 4 for density standard deviation
type - 1 or 5, app_type_id, estimation = 1; prediction = 5
username,password - strings, username and password to connect to the database

Sample
- this plots density
plotDensity(651,139,757,[2013 07 17 00 00 00],[2013 07 17 20 00 00],'ORAlidsI15SB-MainlineOnly',2,1,'username','password')

- this plots density stddev
plotDensity(651,139,757,[2013 07 17 00 00 00],[2013 07 17 20 00 00],'ORAlidsI15SB-MainlineOnly',4,1,'username','password')



--plotVelocity.m------

Plot velocity or velocity stddev of one run

plotVelocity(nid, cid, run_id, startDate, endDate, lidsStr, qty_type, type, username, password)

nid,cid,run_id - network id, config id, run id of the run to be plotted
startDate,endDate - time range of the plot, in the form of [YYYY MM DD HH MM SS], vector of length 6
lidsStr - string, of link ids or of lidsNames, check file listOfLinkIDsNames.m for valid lidsNames
qty_type - 2 or 4, 2 for velocity mean, 4 for velocity standard deviation
type - 1 or 5, app_type_id, estimation = 1; prediction = 5
username,password - strings, username and password to connect to the database



--plot3links.m------

Plot results over 3 links of one single run, mainly helps to identify data on adjacent links with sensors.

plot3links(lid1,lid2,lid3,nid,cid,run_id, startDate, endDate, dataTypeOption, username, password)

lid1,lid2,lid3 - link ids to be plotted
nid,cid,run_id - network id, config id, run id of the run to be plotted
startDate,endDate - time range of the plot, in the form of [YYYY MM DD HH MM SS], vector of length 6
dataTypeOption - string, 'density' or 'velocity', type of data to be plotted
username,password - strings, username and password to connect to the database

Sample
plot3links(197,195,193,649,140,737,[2013 07 17 16 00 00],[2013 07 17 18 00 00],'density','username','password')

**Link ids with sensors on I15SB (mainline in order)
84,98,101,200,105,114,120,133,139,145,154,163,167,169,174,178,182,185,188,191,193,195,197



--plot3runs.m------

Plot results of a single link over 3 runs: simpleaverage, estimation with sensor on link, estimation without sensor on link, respectively.

plot3runs(linkid,n1,c1,r1,n2,c2,r2,n3,c3,r3, startDate,endDate, dataTypeOption, username,password)

linkid - id of the link to be plotted
n1,c1,r1 - network id, config id, run id of simpleaverage run
n2,c2,r2 - network id, config id, run id of estimation run with sensor on this link
n3,c3,r3 - network id, config id, run id of estimation run without sensor on this link
startDate,endDate - time range of the plot, in the form of [YYYY MM DD HH MM SS], vector of length 6
dataTypeOption - string, 'density' or 'velocity', type of data to be plotted
username,password - strings, username and password to connect to the database

Sample
plot3runs(195,649,140,737,693,139,930,692,139,932,[2013 07 17 16 00 00],[2013 07 17 18 00 00],'density','username','password')
