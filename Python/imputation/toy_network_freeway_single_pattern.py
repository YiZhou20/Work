__author__ = 'Yi'

from input_processing import  ProcessIncompleteInputTimeStep
from time_step_one_pattern import ImputeOnePatternTimeStep

input_folder = '../data/NAMEOFPROJECT/Impute/input'
output_folder = '../data/NAMEOFPROJECT/Impute/output'
ProcessIncompleteInputTimeStep(input_folder,1,1)
ImputeOnePatternTimeStep(input_folder,output_folder)
