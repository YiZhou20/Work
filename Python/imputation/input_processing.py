__author__ = 'Yi'
import csv
import numpy
import pandas as pd
from time_to_index_converter import MatchTimeStepData

def ProcessIncompleteInputTimeStep(input_folder, default_flow_weight, default_tr_weight):
    flow_pattern = pd.read_csv(input_folder+'/External_flow_patterns.csv')
    times = list(flow_pattern['DAY'] + ' ' + flow_pattern['TIME_OF_DAY'])

    MatchTimeStepData(input_folder+'/Fuse_combined_flows.csv','flow',input_folder,times,1)
    MatchTimeStepData(input_folder+'/Fuse_combined_turn_ratios.csv','turn ratio',input_folder,times,1)

    ProcessIncompleteInput(input_folder,1,10000,1)

    app_flow = pd.read_csv(input_folder+'/Approach Flows TS.csv')
    length_f = len(app_flow)

    if 'WEIGHT' not in app_flow.columns:
        app_flow['WEIGHT'] = default_flow_weight * numpy.ones(length_f)
    else:
        for i in xrange(length_f):
            if numpy.isnan(app_flow.loc[i,'WEIGHT']):
                app_flow.at[i,'WEIGHT'] = default_flow_weight

    app_flow.to_csv(input_folder+'/Approach Flows TS.csv',index=False)

    turn_ratio = pd.read_csv(input_folder+'/Turn Ratios TS.csv')
    length_t = len(turn_ratio)

    if 'WEIGHT' not in turn_ratio.columns:
        turn_ratio['WEIGHT'] = default_tr_weight * numpy.ones(length_t)
    else:
        for i in xrange(length_t):
            if numpy.isnan(turn_ratio.loc[i,'WEIGHT']):
                app_flow.at[i,'WEIGHT'] = default_tr_weight

    turn_ratio.to_csv(input_folder+'/Turn Ratios TS.csv',index=False)

def ProcessIncompleteInput(input_folder,default_green,default_sat,is_time_sliced):
    ### default_green -- default relative green time, a number in [0,1], usually 1
    ### default_sat -- default saturation flow in veh/hr, usually 3600

    # Imputation Network
    input_network = open(input_folder+'/CreateImpNetwork_imp_network.csv')
    read_network = csv.reader(input_network)
    network_fields = read_network.next()
    index_in = network_fields.index('IN_LINK_ID')
    index_out = network_fields.index('OUT_LINK_ID')

    link_pairs = []
    link_pairs.append([network_fields[index_in],network_fields[index_out]])
    for link_pair in read_network:
        lid_in = link_pair[index_in]
        lid_out = link_pair[index_out]
        link_pairs.append([lid_in,lid_out])

    imp_network = open(input_folder+'/Imputation Network Turns.csv','w')
    write_network = csv.writer(imp_network, lineterminator='\n')
    write_network.writerows(link_pairs)
    input_network.close()
    imp_network.close()

    if not is_time_sliced:
        # Approach Flows
        input_flow = open(input_folder+'/imp_approach_flows.csv')
        read_f = csv.reader(input_flow)
        f_fields = read_f.next()
        index_l = f_fields.index('LINK_ID')
        flows = []
        flows.append(f_fields)
        field_len = len(f_fields)
        links = []
        for link in read_f:
            flows.append(link)
            links.append(link[index_l])

        for l in xrange(1,len(link_pairs)):
            l_pair = link_pairs[l]
            if l_pair[0] not in links:
                links.append(l_pair[0])
                new_flow = [0]*field_len
                new_flow[index_l] = l_pair[0]
                flows.append(new_flow)
            if l_pair[1] not in links:
                links.append(l_pair[1])
                new_flow = [0]*field_len
                new_flow[index_l] = l_pair[1]
                flows.append(new_flow)

        app_flow = open(input_folder+'/Approach Flows.csv','w')
        write_f = csv.writer(app_flow, lineterminator='\n')
        write_f.writerows(flows)
        input_flow.close()
        app_flow.close()

        # Turn Ratios
        input_tr = open(input_folder+'/imp_turn_ratios.csv')
        read_tr = csv.reader(input_tr)
        tr_fields = read_tr.next()
        index_tin = tr_fields.index('IN_LINK_ID')
        index_tout = tr_fields.index('OUT_LINK_ID')
        turn_ratios = []
        turn_ratios.append(tr_fields)
        tr_field_len = len(tr_fields)
        tr_pairs = []
        for tr in read_tr:
            turn_ratios.append(tr)
            tr_pairs.append([tr[index_tin],tr[index_tout]])

        for p in xrange(1,len(link_pairs)):
            l_pair = link_pairs[p]
            if l_pair not in tr_pairs:
                tr_pairs.append(l_pair)
                new_tr = [0]*tr_field_len
                new_tr[index_tin] = l_pair[0]
                new_tr[index_tout] = l_pair[1]
                turn_ratios.append(new_tr)

        turn_ratio = open(input_folder+'/Turn Ratios.csv','w')
        write_tr = csv.writer(turn_ratio, lineterminator='\n')
        write_tr.writerows(turn_ratios)
        input_tr.close()
        turn_ratio.close()

    # Relative Green Times
    input_g = open(input_folder+'/MapToImp_relative_green_times.csv')
    read_g = csv.reader(input_g)
    g_fields = read_g.next()
    index_gin = g_fields.index('IN_LINK_ID')
    index_gout = g_fields.index('OUT_LINK_ID')
    index_g = g_fields.index('RELATIVE_GREEN')
    rel_greens = []
    rel_greens.append(g_fields)
    g_field_len = len(g_fields)
    g_pairs = []
    for g in read_g:
        rel_greens.append(g)
        g_pairs.append([g[index_gin],g[index_gout]])

    for p in xrange(1,len(link_pairs)):
        l_pair = link_pairs[p]
        if l_pair not in g_pairs:
            g_pairs.append(l_pair)
            new_g = [0]*g_field_len
            new_g[index_gin] = l_pair[0]
            new_g[index_gout] = l_pair[1]
            new_g[index_g] = default_green
            rel_greens.append(new_g)

    rel_green = open(input_folder+'/Relative Green Times.csv','w')
    write_g = csv.writer(rel_green, lineterminator='\n')
    write_g.writerows(rel_greens)
    input_g.close()
    rel_green.close()

    # Saturation Flows
    input_s = open(input_folder+'/External_imp_saturation_flows.csv')
    read_s = csv.reader(input_s)
    s_fields = read_s.next()
    index_sin = s_fields.index('IN_LINK_ID')
    index_sout = s_fields.index('OUT_LINK_ID')
    index_s = s_fields.index('SATURATION_FLOW')
    sat_flows = []
    sat_flows.append(s_fields)
    s_field_len = len(s_fields)
    s_pairs = []
    for s in read_s:
        sat_flows.append(s)
        s_pairs.append([s[index_sin],s[index_sout]])

    for p in xrange(1,len(link_pairs)):
        l_pair = link_pairs[p]
        if l_pair not in s_pairs:
            s_pairs.append(l_pair)
            new_s = [0]*s_field_len
            new_s[index_sin] = l_pair[0]
            new_s[index_sout] = l_pair[1]
            new_s[index_s] = default_sat
            sat_flows.append(new_s)

    sat_flow = open(input_folder+'/Saturation Flows.csv','w')
    write_s = csv.writer(sat_flow, lineterminator='\n')
    write_s.writerows(sat_flows)
    input_s.close()
    sat_flow.close()