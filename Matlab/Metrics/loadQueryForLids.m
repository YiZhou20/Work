function [ps, queryString] = loadQueryForLids()
% load all link ids of a network

ps = 'query for link ids of a network';
queryString = ['SELECT id ',...
    'FROM via.links WHERE network_id = ?'];

end