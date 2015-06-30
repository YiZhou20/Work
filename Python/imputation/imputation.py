# the imputation model in Pyomo and solves in Python, with data input and output as csv files
from __future__ import division
__author__ = 'Yi'
from pyomo.environ import *
from pyomo.opt import SolverFactory
import csv

def ModelImputation(input_folder,output_folder):

    opt = SolverFactory('cplex')
#    opt.options["Superbasics_limit"] = 200
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

    def inflow_init(model, link_id):
        output_links = []
        for (link_in, link_out) in model.T:
            if link_in == link_id:
                output_links.append(link_out)
        return output_links

    def outflow_init(model, link_id):
        input_links = []
        for (link_in, link_out) in model.T:
            if link_out == link_id:
                input_links.append(link_in)
        return input_links

    model.Lins = Set(model.Lin, initialize=inflow_init)
    model.Louts = Set(model.Lout, initialize=outflow_init)

    # Input parameters
    model.f = Param(model.L) # measured/default flow in veh/h, 0 if no measurement
    model.a = Param(model.L) # weights on measured/default flows, 0 for no measurement
    model.r = Param(model.T) # measured/default turn ratio in [0,1]
    model.b = Param(model.T) # weights on measured/default turn ratios, 0 for no measurement
    model.g = Param(model.T) # relative green time in [0,1]
    model.s = Param(model.T) # saturation flow in veh/h

    # More sets
    def fixflow_init(model):
        fix_flow_links = []
        for link_id in model.L:
            if str(model.a[link_id]).lower() == 'inf':
                fix_flow_links.append(link_id)
        return fix_flow_links
    model.F = Set(initialize=fixflow_init)            # set of links which flow values are fixed
    model.N = model.L - model.F                       # set of links which flow values are to be imputed

    # Decision Variables
    model.x = Var(model.L, domain = NonNegativeReals) # imputed flow in veh/h
    model.y = Var(model.T, domain = NonNegativeReals) # imputed turn flow in veh/h
#    model.t = Var(model.T, domain = NonNegativeReals) # 'measured' turn flow in veh/h

    # Objective
    def obj_expression(model):
#        return sum(model.a[l] * pow(model.x[l] - model.f[l],2) for l in model.N) + sum(model.b[m,n] * pow(model.y[m,n] - model.t[m,n],2) for [m,n] in model.T)
        return sum(model.a[l] * pow(model.x[l] - model.f[l],2) for l in model.N) + sum(model.b[m,n] * pow(model.y[m,n] - model.r[m,n] * model.x[m],2) for [m,n] in model.T)
    model.OBJ = Objective(rule=obj_expression, sense=minimize)

    # Constraints
    # Fixed Flows on Specified Links
    def fix_flow(model,l):
        return model.x[l] == model.f[l]
    model.fixflow = Constraint(model.F, rule=fix_flow)

    # Flow Balance
    def inflow_balance(model,m):
        return sum(model.y[m,n] for n in model.Lins[m]) == model.x[m]
    def outflow_balance(model,n):
        return sum(model.y[m,n] for m in model.Louts[n]) == model.x[n]

    model.inflow = Constraint(model.Lin, rule=inflow_balance)
    model.outflow = Constraint(model.Lout, rule=outflow_balance)

    # Calculate 'Measured' Turn Flows
#    def measured_turnflow(model,m,n):
#        return model.t[m,n] == model.r[m,n] * model.x[m]

#    model.turnflow = Constraint(model.T, rule=measured_turnflow)

    # Turn Capacity
    def turn_capacity(model,m,n):
        return model.y[m,n] <= model.g[m,n] * model.s[m,n]

    model.capacity = Constraint(model.T, rule=turn_capacity)

    # Load Data
    data = DataPortal(model=model)
    data.load(filename=input_folder+'/Imputation Network Turns.csv', set=model.T)
    data.load(filename=input_folder+'/Approach Flows.csv', select=('LINK_ID','FLOW','WEIGHT'), param=(model.f,model.a), index=model.L)
    data.load(filename=input_folder+'/Turn Ratios.csv',select=('IN_LINK_ID','OUT_LINK_ID','TURN_RATIO','WEIGHT'),param=(model.r,model.b),index=model.T)
    data.load(filename=input_folder+'/Relative Green Times.csv',select=('IN_LINK_ID','OUT_LINK_ID','RELATIVE_GREEN'), param=model.g, index=model.T)
    data.load(filename=input_folder+'/Saturation Flows.csv',select=('IN_LINK_ID','OUT_LINK_ID','SATURATION_FLOW'), param=model.s, index=model.T)

    # Solve
    instance = model.create(data)
    results = opt.solve(instance)

    # Write output
    instance.load(results)
    # Flows
    app_flows = open(input_folder+'/Approach Flows.csv')
    read_f = csv.reader(app_flows)
    imp_flows = open(output_folder+'/Imputed Approach Flows.csv','w')
    write_f = csv.writer(imp_flows, lineterminator='\n')

    f_all = []
    f_field = read_f.next()
    f_field.append('EST_FLOW')
    f_field.append('IS_SOURCE')
    f_all.append(f_field)
    index = f_field.index('LINK_ID')
    for link in read_f:
        lid = int(link[index])
        link.append(instance.x[lid].value)
        if lid not in instance.Lout:
            link.append(1)
        else:
            link.append(0)
        f_all.append(link)
    write_f.writerows(f_all)
    app_flows.close()
    imp_flows.close()

    # Turn Ratios
    meas_trs = open(input_folder+'/Turn Ratios.csv')
    read_tr = csv.reader(meas_trs)
    imp_trs = open(output_folder+'/Imputed Turn Ratios.csv','w')
    write_tr = csv.writer(imp_trs, lineterminator='\n')

    tr_all = []
    tr_field = read_tr.next()
    tr_field.append('EST_TURN_RATIO')
    tr_field.append('EST_TURN_FLOW')
    tr_field.append('TURN_CAPACITY')
    tr_all.append(tr_field)
    in_index = tr_field.index('IN_LINK_ID')
    out_index = tr_field.index('OUT_LINK_ID')
    for link_pair in read_tr:
        lid_in = int(link_pair[in_index])
        lid_out = int(link_pair[out_index])
        est_t = instance.y[lid_in,lid_out].value
        if est_t == 0:
            est_tr = 0
        else:
            est_tr = est_t/instance.x[lid_in].value
        link_pair.append(est_tr)
        link_pair.append(est_t)
        link_pair.append(instance.g[lid_in,lid_out]*instance.s[lid_in,lid_out])
        tr_all.append(link_pair)
    write_tr.writerows(tr_all)
    meas_trs.close()
    imp_trs.close()

    # Objective Value
    f_obj_val = open(output_folder+'/Objective Value.csv','w')
#    obj_val = sum(instance.a[l] * pow(instance.x[l].value - instance.f[l],2) for l in instance.N) + sum(instance.b[m,n] * pow(instance.y[m,n].value - instance.t[m,n].value,2) for [m,n] in instance.T)
    obj_val = sum(instance.a[l] * pow(instance.x[l].value - instance.f[l],2) for l in instance.N) + sum(instance.b[m,n] * pow(instance.y[m,n].value - instance.r[m,n] * instance.x[m].value,2) for [m,n] in instance.T)
    f_obj_val.write(str(obj_val))
    f_obj_val.close()
    return obj_val
