__author__ = 'Yi'
import csv
from imputation import ModelImputation
from input_processing import  ProcessIncompleteInput

def ImputeIndependentTimeStep(input_folder, output_folder, default_green, default_sat, times, is_tr_ts):
    agg_f_out = []
    agg_t_out = []
    obj_vals = []
    obj_vals.append(['OBJ_VAL','DAY','TIME_OF_DAY'])
    for time_slice in times:
        ts_flow = open(input_folder+'/Approach Flows TS.csv')
        ts_flow_reader = csv.reader(ts_flow)
        flow_fields = ts_flow_reader.next()
        flow_index_day = flow_fields.index('DAY')
        flow_index_time_before = flow_fields.index('TIME_OF_DAY')
        flow_fields.pop(flow_index_day)
        flow_index_time_after = flow_fields.index('TIME_OF_DAY')
        flow_fields.pop(flow_index_time_after)
        flow_t = []
        flow_t.append(flow_fields)
        for flow in ts_flow_reader:
            if [flow[flow_index_day],flow[flow_index_time_before]] == time_slice:
                flow.pop(flow_index_day)
                flow.pop(flow_index_time_after)
                flow_t.append(flow)
        app_flow = open(input_folder+'/imp_approach_flows.csv','w')
        write_f = csv.writer(app_flow, lineterminator='\n')
        write_f.writerows(flow_t)
        ts_flow.close()
        app_flow.close()
        if is_tr_ts:
            ts_tr = open(input_folder+'/Turn Ratios TS.csv')
            ts_tr_reader = csv.reader(ts_tr)
            tr_fields = ts_tr_reader.next()
            tr_index_day = tr_fields.index('DAY')
            tr_index_time_before = tr_fields.index('TIME_OF_DAY')
            tr_fields.pop(tr_index_day)
            tr_index_time_after = tr_fields.index('TIME_OF_DAY')
            tr_fields.pop(tr_index_time_after)
            tr_t = []
            tr_t.append(tr_fields)
            for tr in ts_tr_reader:
                if [tr[tr_index_day],tr[tr_index_time_before]] == time_slice:
                    tr.pop(tr_index_day)
                    tr.pop(tr_index_time_after)
                    tr_t.append(tr)
            turn_ratio = open(input_folder+'/imp_turn_ratios.csv','w')
            write_t = csv.writer(turn_ratio, lineterminator='\n')
            write_t.writerows(tr_t)
            ts_tr.close()
            turn_ratio.close()
        ProcessIncompleteInput(input_folder,default_green,default_sat,0)
        ModelImputation(input_folder,input_folder)
        est_flow = open(input_folder+'/Imputed Approach Flows.csv')
        read_f = csv.reader(est_flow)
        f_fields = read_f.next()
        if agg_f_out == []:
            f_fields.append('DAY')
            f_fields.append('TIME_OF_DAY')
            agg_f_out.append(f_fields)
        for est_f in read_f:
            est_f.append(time_slice[0])
            est_f.append(time_slice[1])
            agg_f_out.append(est_f)
        est_flow.close()
        est_tr = open(input_folder+'/Imputed Turn Ratios.csv')
        read_t = csv.reader(est_tr)
        t_fields = read_t.next()
        if agg_t_out == []:
            t_fields.append('DAY')
            t_fields.append('TIME_OF_DAY')
            agg_t_out.append(t_fields)
        for est_t in read_t:
            est_t.append(time_slice[0])
            est_t.append(time_slice[1])
            agg_t_out.append(est_t)
        est_tr.close()
        obj = open(input_folder+'/Objective Value.csv')
        obj_vals.append([obj.read(),time_slice[0],time_slice[1]])
        obj.close()

    agg_flow = open(output_folder+'/Impute_Imputed_Approach_Flows_TS.csv','w')
    write_agg_f = csv.writer(agg_flow, lineterminator='\n')
    write_agg_f.writerows(agg_f_out)
    agg_flow.close()
    agg_tr = open(output_folder+'/Impute_Imputed_Turn_Ratios_TS.csv','w')
    write_agg_t = csv.writer(agg_tr, lineterminator='\n')
    write_agg_t.writerows(agg_t_out)
    agg_tr.close()
    objective = open(output_folder+'/Objective Values.csv','w')
    write_obj = csv.writer(objective, lineterminator='\n')
    write_obj.writerows(obj_vals)
    objective.close()
