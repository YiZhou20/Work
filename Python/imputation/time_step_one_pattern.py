# time-slicing, one pattern fitting
from __future__ import division
__author__ = 'Yi'
from pyomo.environ import *
from pyomo.opt import SolverFactory
import csv

def ImputeOnePatternTimeStep(input_folder, output_folder):

    opt = SolverFactory('cplex')
    model = AbstractModel()
    # Sets
    model.T = Set(dimen=2)                   # set of all link pairs

    def lin_init(model):
        in_links = []
        for (link_in, link_out) in model.T:
            if link_in not in in_links:
                in_links.append(link_in)
        return in_links

    def lout_init(model):
        out_links = []
        for (link_in, link_out) in model.T:
            if link_out not in out_links:
                out_links.append(link_out)
        return out_links

    model.Lin = Set(initialize=lin_init)     # set of all links except sinks
    model.Lout = Set(initialize=lout_init)   # set of all links except sources
    model.L = model.Lin | model.Lout         # set of all links in the network

    model.K = Set()                          # set of all time slices
    model.LK = model.L * model.K
    model.TK = model.T * model.K
    model.LKin = model.Lin * model.K
    model.LKout = model.Lout * model.K

    def inflow_init(model, link_id):
        output_links = []
        for (link_in, link_out) in model.T:
            if (link_in == link_id):
                output_links.append(link_out)
        return output_links

    def outflow_init(model, link_id):
        input_links = []
        for (link_in, link_out) in model.T:
            if (link_out == link_id):
                input_links.append(link_in)
        return input_links

    model.Lins = Set(model.Lin, initialize=inflow_init)
    model.Louts = Set(model.Lout, initialize=outflow_init)


    # Input parameters
    model.f = Param(model.LK, default = 0)           # measured/default flow in veh/h, 0 if no measurement
    model.a = Param(model.LK, default = 0)           # weights on measured/default flows, 0 for no measurement
    model.r = Param(model.TK, default = 0)           # measured/default turn ratio in [0,1]
    model.b = Param(model.TK, default = 0)           # weights on measured/default turn ratios, 0 for no measurement
    model.g = Param(model.T)            # relative green time in [0,1]
    model.s = Param(model.T)            # saturation flow in veh/h
#    model.adt = Param(model.L)          # measured all day total flow in veh/h
#    model.q = Param(model.L)            # weights on measured all day total flow
#    model.p = Param(model.LK)           # weights on flow pattern
    model.med = Param(model.K)          # median flow proportions in pattern
    model.lb = Param(model.K)           # lower bound flow proportions in pattern
    model.ub = Param(model.K)           # upper bound flow proportions in pattern

    # More sets
    def fixflow_init(model):
        fix_flow_links = []
        for (link,time) in model.LK:
            if str(model.a[link,time]).lower() == 'inf':
                fix_flow_links.append([link,time])
        return fix_flow_links
    model.FK = Set(dimen=2, initialize=fixflow_init)            # set of links which flow values are fixed
    model.NK = model.LK - model.FK                     # set of links which flow values are to be imputed

    # Decision Variables
    model.x = Var(model.LK, domain = NonNegativeReals)     # imputed flow in veh/h
    model.y = Var(model.TK, domain = NonNegativeReals)     # imputed turn flow in veh/h
    model.t = Var(model.TK, domain = NonNegativeReals)     # 'measured' turn flow in veh/h
    model.ftotal = Var(model.L, domain = NonNegativeReals) # imputed all day total flow in veh/h

    # Objective
    def obj_expression(model):
#        return sum(model.a[l,k] * pow(model.x[l,k] - model.f[l,k],2) for [l,k] in model.NK) + sum(model.b[m,n,k] * pow(model.y[m,n,k] - model.t[m,n,k],2) for [m,n,k] in model.TK) + \
#            sum(model.q[l] * pow(model.ftotal[l] - model.adt[l],2) for l in model.L) + sum(model.p[l,k] * pow(model.x[l,k] - model.med[k] * model.ftotal[l],2) for [l,k] in model.LK)
        return sum(model.a[l,k] * pow(model.x[l,k] - model.f[l,k],2) for [l,k] in model.NK) + sum(model.b[m,n,k] * pow(model.y[m,n,k] - model.t[m,n,k],2) for [m,n,k] in model.TK) + \
            sum(pow(model.x[l,k] - model.med[k] * model.ftotal[l],2) for [l,k] in model.LK)
    model.OBJ = Objective(rule=obj_expression, sense=minimize)

    # Constraints
    # Calculate 'Measured' Turn Flows
    def measured_turnflow(model,m,n,k):
        return model.t[m,n,k] == model.r[m,n,k] * model.x[m,k]
    model.turnflow = Constraint(model.TK, rule=measured_turnflow)

    # Calculate Imputed All Day Total Flow
    def all_day_total_flow(model,l):
        return model.ftotal[l] == sum(model.x[l,k] for k in model.K)
    model.alldaytotal = Constraint(model.L, rule=all_day_total_flow)

    # Fixed Flows on Specified Links
    def fix_flow(model,l,k):
        return model.x[l,k] == model.f[l,k]
    model.fixflow = Constraint(model.FK, rule=fix_flow)

    # Flow Balance
    def inflow_balance(model,m,k):
        return sum(model.y[m,n,k] for n in model.Lins[m]) == model.x[m,k]
    def outflow_balance(model,n,k):
        return sum(model.y[m,n,k] for m in model.Louts[n]) == model.x[n,k]

    model.inflow = Constraint(model.LKin, rule=inflow_balance)
    model.outflow = Constraint(model.LKout, rule=outflow_balance)

    # Turn Capacity
    def turn_capacity(model,m,n,k):
        return model.y[m,n,k] <= model.g[m,n] * model.s[m,n]
    model.capacity = Constraint(model.TK, rule=turn_capacity)

    # Lower and Upper Bound of Flow Pattern
    def lower_bound_fit(model,l,k):
        return model.x[l,k] >= model.lb[k] * model.ftotal[l]
    def upper_bound_fit(model,l,k):
        return model.x[l,k] <= model.ub[k] * model.ftotal[l]

    model.lowerbound = Constraint(model.LK, rule=lower_bound_fit)
    model.upperbound = Constraint(model.LK, rule=upper_bound_fit)

    # Load Data
    data = DataPortal(model=model)
    data.load(filename=input_folder+'/Imputation Network Turns.csv', set=model.T)
    data.load(filename=input_folder+'/External_flow_patterns.csv', select=('TIME_OF_DAY','MEDIAN','LOWER_BOUND','UPPER_BOUND'), param=(model.med,model.lb,model.ub), index=model.K)
    data.load(filename=input_folder+'/Approach Flows TS.csv', select=('LINK_ID','TIME_OF_DAY','FLOW','WEIGHT'), param=(model.f,model.a), index=model.LK)
    data.load(filename=input_folder+'/Turn Ratios TS.csv',select=('IN_LINK_ID','OUT_LINK_ID','TIME_OF_DAY','TURN_RATIO','WEIGHT'),param=(model.r,model.b),index=model.TK)
    data.load(filename=input_folder+'/Relative Green Times.csv',select=('IN_LINK_ID','OUT_LINK_ID','RELATIVE_GREEN'), param=model.g, index=model.T)
    data.load(filename=input_folder+'/Saturation Flows.csv',select=('IN_LINK_ID','OUT_LINK_ID','SATURATION_FLOW'), param=model.s, index=model.T)

    # Solve
    instance = model.create(data)
    results = opt.solve(instance)

    # Write output
    instance.load(results)
    # Flows
    app_flows = open(input_folder+'/Approach Flows TS.csv')
    read_f = csv.reader(app_flows)
    imp_flows = open(input_folder+'/Imputed Approach Flows TS Measured.csv','w')
    write_f = csv.writer(imp_flows, lineterminator='\n')

    f_all = []
    f_field = read_f.next()
    f_field.append('EST_FLOW')
    f_field.append('IS_SOURCE')
    f_all.append(f_field)
    index = f_field.index('LINK_ID')
    t_idx_f = f_field.index('TIME_OF_DAY')
    for link in read_f:
        lid = long(link[index])
        l_ts = link[t_idx_f]
        link.append(instance.x[lid,l_ts].value)
        if lid not in instance.Lout:
            link.append(1)
        else:
            link.append(0)
        f_all.append(link)
    write_f.writerows(f_all)
    app_flows.close()
    imp_flows.close()

    imp_flows_all = open(output_folder+'/Impute_Imputed_Approach_Flows_TS.csv','w')
    write_f_all = csv.writer(imp_flows_all, lineterminator='\n')

    f_all = []
    f_all.append(['LINK_ID','TIME_OF_DAY','EST_FLOW','IS_SOURCE'])
    for (lid,l_ts) in instance.LK:
        if lid not in instance.Lout:
            f_all.append([lid,l_ts,instance.x[lid,l_ts].value,1])
        else:
            f_all.append([lid,l_ts,instance.x[lid,l_ts].value,0])
    write_f_all.writerows(f_all)
    imp_flows_all.close()

    meas_trs = open(input_folder+'/Turn Ratios TS.csv')
    read_tr = csv.reader(meas_trs)
    imp_trs = open(input_folder+'/Imputed Turn Ratios TS Measured.csv','w')
    write_tr = csv.writer(imp_trs, lineterminator='\n')

    tr_all = []
    tr_field = read_tr.next()
    tr_field.append('EST_TURN_RATIO')
    tr_field.append('EST_TURN_FLOW')
    tr_field.append('TURN_CAPACITY')
    tr_all.append(tr_field)
    in_index = tr_field.index('IN_LINK_ID')
    out_index = tr_field.index('OUT_LINK_ID')
    t_idx_t = tr_field.index('TIME_OF_DAY')
    for link_pair in read_tr:
        lid_in = long(link_pair[in_index])
        lid_out = long(link_pair[out_index])
        lp_ts = link_pair[t_idx_t]
        est_t = instance.y[lid_in,lid_out,lp_ts].value
        if est_t == 0:
            est_tr = 0
        else:
            est_tr = est_t/instance.x[lid_in,lp_ts].value
        link_pair.append(est_tr)
        link_pair.append(est_t)
        link_pair.append(instance.g[lid_in,lid_out]*instance.s[lid_in,lid_out])
        tr_all.append(link_pair)
    write_tr.writerows(tr_all)
    meas_trs.close()
    imp_trs.close()

    imp_trs_all = open(output_folder+'/Impute_Imputed_Turn_Ratios_TS.csv','w')
    write_tr_all = csv.writer(imp_trs_all, lineterminator='\n')

    tr_all = []
    tr_all.append(['IN_LINK_ID','OUT_LINK_ID','TIME_OF_DAY','EST_TURN_RATIO','EST_TURN_FLOW','TURN_CAPACITY'])
    for (lid_in,lid_out,lp_ts) in instance.TK:
        est_t = instance.y[lid_in,lid_out,lp_ts].value
        turn_cap = instance.g[lid_in,lid_out]*instance.s[lid_in,lid_out]
        if est_t == 0:
            tr_all.append([lid_in,lid_out,lp_ts,est_t/instance.x[lid_in,lp_ts].value,est_t,turn_cap])
        else:
            tr_all.append([lid_in,lid_out,0,est_t,turn_cap])
    write_tr_all.writerows(tr_all)
    imp_trs_all.close()

    # Objective Value
    f_obj_val = open(output_folder+'/Objective Value.csv','w')
    obj_val = sum(instance.a[l,k] * pow(instance.x[l,k].value - instance.f[l,k],2) for [l,k] in instance.NK) + sum(instance.b[m,n,k] * pow(instance.y[m,n,k].value - instance.t[m,n,k].value,2) for [m,n,k] in instance.TK)
    f_obj_val.write(str(obj_val))
    f_obj_val.close()
    return obj_val