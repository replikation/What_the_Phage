#!/usr/bin/env python

import pandas as pd
import numpy as np
import argparse


parser = argparse.ArgumentParser(description='Process virnet files')
parser.add_argument(
    '--input', required=True, help='csv output from virnet')
parser.add_argument(
    '--output', required=True, help='Where to save the positive contig list')
args = parser.parse_args()


# load csv into panda frame
df = pd.read_csv(args.input)
# split description to get "pure" contig names
df[['contig_name','hash']] = df.ID.str.split(",", expand=True)
# drop unneccesary columns
df=df.drop(columns=['ID', 'DESC', 'hash','result']).drop(df.columns[0], axis=1)
# calculate median
df = df.groupby("contig_name").median()

# write to file 
df.to_csv(args.output, sep='\t', header=False)