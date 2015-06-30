function route_lids = loadRouteLinks(rid)

import edu.berkeley.path.pemsviz.*;
global gb_conn
pemsreader = PemsReader(gb_conn);


[ps, queryString] = loadQueryForRoute();

route_lids = [];

success = pemsreader.createRouteQuery(ps, queryString, num2str(rid));
pemsreader.executePemsCountQuery();
while pemsreader.hasNextRow()
    lid = pemsreader.getRowResult('link_id');
    route_lids = [route_lids, lid];
end