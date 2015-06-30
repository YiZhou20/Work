__author__ = 'Yi'

from input_processing import ProcessIncompleteInput
from imputation import ModelImputation
import pandas as pd
import numpy as np

input_folder = '..\data\NAMEOFPROJECT\Impute\input'
output_folder = '..\data\NAMEOFPROJECT\Impute\output'
ProcessIncompleteInput(input_folder,1,10000,0)
ModelImputation(input_folder,output_folder)
