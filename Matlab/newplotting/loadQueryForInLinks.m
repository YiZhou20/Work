function [ps, queryString] = loadQueryForInLinks()

% load input links at an intersection
ps = 'query for input links at an intersection';
queryString = ['SELECT id FROM via.links ' ...
    'WHERE network_id = ? AND end_node_id = ?'];
end
