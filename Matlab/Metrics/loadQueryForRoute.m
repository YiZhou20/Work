function [ps, queryString] = loadQueryForRoute()
% load link ids for a route

ps = 'query for link ids of a route';
queryString = ['SELECT link_id ',...
    'FROM via.route_links WHERE route_id = ? ORDER BY link_order'];

end