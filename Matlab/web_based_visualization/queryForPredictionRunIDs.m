function [ps, queryString] = queryForPredictionRunIDs()
% Query to get prediction runs associated with an estimation run
ps = 'query for prediction run ids of a specified estimation run';
queryString = [...
    'SELECT pred_app_run_id ',...
    'FROM via.dyn_predictions ',...
    'WHERE est_app_run_id = ?'];