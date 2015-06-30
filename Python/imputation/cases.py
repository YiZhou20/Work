__author__ = 'Yi'

from input_processing import ProcessIncompleteInput
from imputation import ModelImputation
import pandas as pd
import numpy as np

input_folder = '..\data\Toy_Network\output'
ProcessIncompleteInput(input_folder,1,3600,0)
output_folder = 'output\Toy_Network'
ModelImputation(input_folder,output_folder)


app_flow = pd.read_csv('output\Toy_Network\Imputed Approach Flows.csv')
app_flow['ABS_DIFF'] = abs(app_flow['FLOW']-app_flow['EST_FLOW'])
app_flow['REL_DIFF'] = app_flow['ABS_DIFF']/app_flow['FLOW']

turn_ratio = pd.read_csv('output\Toy_Network\Imputed Turn Ratios.csv')

meas_flow = pd.read_csv('..\data\Toy_Network\output\imp_approach_flows.csv')
lids = list(meas_flow['LINK_ID'])

for p in xrange(0,len(turn_ratio)):
    in_link = turn_ratio.loc[p,'IN_LINK_ID']
    if in_link in lids:
        l_idx = lids.index(in_link)
        l_meas_flow = meas_flow.loc[l_idx,'FLOW']
        l_turn_ratio = turn_ratio.loc[p,'TURN_RATIO']

        turn_ratio.at[p,'TURN_FLOW'] = l_turn_ratio * l_meas_flow

turn_ratio['ABS_FLOW_VOL_DIFF'] = abs(turn_ratio['TURN_FLOW']-turn_ratio['EST_TURN_FLOW'])
turn_ratio['REL_FLOW_VOL_DIFF'] = turn_ratio['ABS_FLOW_VOL_DIFF']/turn_ratio['TURN_FLOW']

turn_ratio['TURN_RATIO_DIFF'] = abs(turn_ratio['TURN_RATIO']-turn_ratio['EST_TURN_RATIO'])

app_flow.to_csv('approach_flows_comparison.csv', index=False)
turn_ratio.to_csv('turn_ratios_comparison.csv', index=False)