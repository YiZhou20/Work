function num_lanes = get_number_lanes(nid,lidstr)

ps = 'query for number of lanes of specified links';
queryString = ['SELECT lane_count ',...
    'FROM via.links WHERE network_id = ? ',...
    'AND id in (', lidstr, ') ORDER BY ',...
    'Instr(''',lidstr,''','','' || id || '','' )'];

addpath ../pems_data_visualization
import edu.berkeley.path.pemsviz.*;
global gb_conn
pemsreader = PemsReader(gb_conn);

num_lanes = [];
success = pemsreader.createLaneNumberQuery(ps, queryString, num2str(nid));
pemsreader.executePemsCountQuery();
while pemsreader.hasNextRow()
    num_lanes = [num_lanes, pemsreader.getRowResult('lane_count')];
end
