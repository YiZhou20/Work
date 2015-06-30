__author__ = 'Yi'

from time_step_indep import ImputeIndependentTimeStep
from time_to_index_converter import CreateTimeIndex,MatchTimeStepData

times = CreateTimeIndex(['03-Feb-2014','00:00:00'],['03-Feb-2014','23:55:00'], 5)
input_folder = '../data/NAMEOFPROJECT/Impute/input'
output_folder = '../data/NAMEOFPROJECT/Impute/output'
MatchTimeStepData(input_folder+'/Fuse_combined_flows.csv','flow',input_folder,times,0)
MatchTimeStepData(input_folder+'/Fuse_combined_turn_ratios.csv','turn ratio',input_folder,times,0)
ImputeIndependentTimeStep(input_folder, output_folder, 1, 10000, times, 1)