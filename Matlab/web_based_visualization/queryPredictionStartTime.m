function [ps, queryString] = queryPredictionStartTime()
% Query to get the start time of a prediction run
ps = 'query for start time of a prediction run';
queryString = ['SELECT EXTRACT(YEAR FROM min(TS)) AS year, '...
    'EXTRACT(MONTH FROM min(TS)) AS month, EXTRACT(DAY FROM min(TS)) AS day, '...
    'EXTRACT(HOUR FROM min(TS)) AS hour, EXTRACT(MINUTE FROM min(TS)) AS minute, '...
    'EXTRACT(SECOND FROM min(TS)) AS second '...
    'FROM via.link_data_total WHERE app_run_id = ?'];