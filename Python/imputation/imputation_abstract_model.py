# just the abstract model itself
from __future__ import division
from pyomo.environ import *

model = AbstractModel()
# Sets
model.L = Set()          # set of all links in the network
model.Lin = Set()        # set of all links except sinks
model.Lout = Set()       # set of all links except sources
model.T = Set(dimen=2)   # set of all link pairs

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
# Decision Variables
model.x = Var(model.L, domain = NonNegativeReals) # imputed flow in veh/h
model.y = Var(model.T, domain = NonNegativeReals) # imputed turn flow in veh/h
model.t = Var(model.T, domain = NonNegativeReals) # 'measured' turn flow in veh/h

# Objective
def obj_expression(model):
    return sum(model.a[l] * pow(model.x[l] - model.f[l],2) for l in model.L) + sum(model.b[m,n] * pow(model.y[m,n] - model.t[m,n],2) for [m,n] in model.T)
model.OBJ = Objective(rule=obj_expression, sense=minimize)

# Constraints
# Flow Balance
def inflow_balance(model,m):
    return sum(model.y[m,n] for n in model.Lins[m]) == model.x[m]
def outflow_balance(model,n):
    return sum(model.y[m,n] for m in model.Louts[n]) == model.x[n]

model.inflow = Constraint(model.Lin, rule=inflow_balance)
model.outflow = Constraint(model.Lout, rule=outflow_balance)

# Calculate 'Measured' Turn Flows
def measured_turnflow(model,m,n):
    return model.t[m,n] == model.r[m,n] * model.x[m]

model.turnflow = Constraint(model.T, rule=measured_turnflow)

# Turn Capacity
def turn_capacity(model,m,n):
    return model.y[m,n] <= model.g[m,n] * model.s[m,n]

model.capacity = Constraint(model.T, rule=turn_capacity)


