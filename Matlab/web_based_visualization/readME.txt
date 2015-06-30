--webVisualize.m-----

IMPORTANT:
For this function to operate correctly, place the following files into the directory where you would like to see outputs:
spacer.png
index.html (home page)
density folder
velocity folder

Given an estimation run_id and a time range, this function plots estimation and associated prediction results and generates html pages.
Figures are each a 15min piece, stored by data types then by run_ids.

webVisualize(erun_id, startDate, endDate, username, password, lidsName, saveDir, n)

erun_id - an estimation run_id
startDate, endDate - time range to plot, in form [YYYY MM DD HH MM SS], vector of length 6
username, password - strings, username and password to connect to the database
lidsName - a string, of the name for link ids, or of link ids themselves, check file newplotting/listOfLinkIDsNames.m for valid lidsNames
saveDir - a string, of the directory where the files and folders listed above are
n - optional, 1,2,3 or 4, default: 4. Time pieces of a prediction run to be plotted. A prediction run has 1hr time range.

Sample Usage:
webVisualize(3336, [2013 10 08 05 00 00], [2013 10 08 10 00 00], 'yizhou', 'shmilm20', 'I15Sv56', 'C:/Users/GSR03/WebResults/')
webVisualize(3373, [2013 10 08 07 00 00], [2013 10 08 08 00 00], 'yizhou', 'shmilm20', 'I15Sv56', 'C:/Users/GSR03/WebResults/', 3)