function [ps, queryString] = loadQueryForOutLinks()

% load output links at an intersection
ps = 'query for output links at an intersection';
queryString = ['SELECT id FROM via.links ' ...
    'WHERE network_id = ? AND beg_node_id = ?'];
end