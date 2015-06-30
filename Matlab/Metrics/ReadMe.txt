Steps to Run Metrics over Routes

0 Preparation !IMPORTANT!
**pull the latest version of freeway repo from YiZhou20/freeway.git (master branch)
**mvn clean install freeway
**mvn clean install freeway/tools/MATLAB/plotting/java/readldt
**mvn clean install freeway/tools/MATLAB/pems_data_visualization/java/pemsviz

1 Make sure the routes of interest are in DB ROUTES and ROUTE_LINKS (and ROUTE_SETS) tables correctly
**know the ids of these routes

2 Set up Connection
**in freeway/tools/MATLAB/Metrics
**setEnvironment;
**setImport;
**createConnection('dbUsername','dbPassword','ccoradb.path.berkeley.edu');

3 Fetch Data
[links, velocities, densities, times, link_lengths, total_lids, start_date, end_date] = ... 
    collectRouteData(rids, nid, run_id, startDate, endDate, app_type_id);
**inputs
    rids               -- route ids of interest in a vector, order does not matter
    nid                -- network id
    run_id             -- run id
    startDate, endDate -- desired time box for data fetching, vectors in format [YYYY MM DD HH MI SS]
    app_type_id        -- 1 for an estimation run, 5 for a prediction run
**outputs
    links                -- link ids repeated over time steps
    velocities           -- speed in m/s, one record for each link at each time step
    densities            -- density in veh/m, one record for each link at each time step
    times                -- time steps, repeated over links
    link_lengths         -- length in meters, one record for each link
    total_lids           -- all link ids in input routes, NOT repeated over time steps, NO duplicates, same order as link_lengths follow
    start_date, end_date -- actual start time, end time where there is data, vectors in format [YYYY MM DD HH MI SS]
**fetching data takes long, especially for long routes
**routes CANNOT be too long -- all link ids in input routes (NO duplicates) in a string CANNOT exceed 4000 characters (roughly 300+ links
    total) at a time, violation will immediately shut MATLAB down, usually not even an error message
**results will be autosaved to data.mat, RENAME (as it overwrites) this if intend to use same data later -- loading is a LOT faster
**fetch more data to the end if interested in travel time over congestion periods -- metrics are not calculated if trip not completed in
    fetched data (i.e. run goes over 4-8pm, want metrics over 5-6pm where congestion happens, fetch data over 5-7pm)
**start_date and end_date help when the run duration is uncertain, good reference for next step (i.e. run actually goes 4-8pm,
    enter 2-10pm for data fetching, results will show start_date[YYYY MM DD 16 00 00], end_date[YYYY MM DD 20 00 00])
*SAMPLE*
[links, velocities, densities, times, link_lengths, total_lids, start_date, end_date] = ... 
collectRouteData([8 9 10 11 12 13 14 15], 1138, 4836, [2014 02 03 16 30 00], [2014 02 03 17 00 00], 5);

4 Calculate and Plot Metrics
[rs,vht,vmt,total_delay,travel_time,delay_from_travel_time] = ...
    metrics_vis(routes, nid, run_id, startDate, endDate, agg_period, dt, report_dt, v_l, ... 
    links, velocities, densities, times, link_lengths, total_lids, movement, approach)
**inputs
    links, velocities, densities, times, link_lengths, total_lids are outputs from previous step
    nid, run_id        -- network id, run id, same as previous step, only for titling plots
    startDate, endDate -- time box to calculate metrics (this function handles unavailable data issue, but to save time,
        refer to previous step outputs for more accurate inputs)
    agg_period         -- calculation period of metrics, in minutes between 0 and 60 (i.e. put 0.5 for 30 seconds)
                           should be a multiple of dt
    dt                 -- simulation timestamp in seconds, currently usually 2
    report_dt          -- reporting interval to DB in seconds
    v_l                -- a number, freeflow speed in mph
    routes             -- matrix of route ids up to size 3*4, order matters to get plot legends correct
                           rows as movement types, e.g. through/left
                           columns as approach direction, e.g. north/south
                           put in 0 to skip
    movement           -- cell array up to size 1*3 that specifies rows of routes
                           optional, DEFAULT {'thru','left','right'}
    approach           -- cell array up to size 1*4 that specifies columns of routes
                           optional, DEFAULT {'N','S','E','W'}
**this metrics calculation was mostly intended for intersections, feel free to customize the routes matrix, just match it with customized 
    movement and approach inputs to get illustrative legends in plots
**to use default legends correctly, put route ids in matrix form [NT,ST,ET,WT;NL,SL,EL,WL;NR,SR,ER,WR]
    N,S,E,W -- approach direction, north, south, east, west
    T,L,R   -- movement, through, left, right
**current version only allows one value for freeflow speed, try to calculate separately for routes that do not have similar freeflows

*SAMPLE*
[rs,vht,vmt,total_delay,travel_time,delay_from_travel_time] = metrics_vis([8,10,12,14;9,11,13,15], 1138, 4836, ... 
[2014 02 03 16 30 00], [2014 02 03 17 00 00], 0.5, 2, 30, 38.028, links, velocities, densities, times, link_lengths, total_lids);

