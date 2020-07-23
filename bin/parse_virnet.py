#!/usr/bin/env python

import pandas as pd
import numpy as np
import argparse


parser = argparse.ArgumentParser(description='Process virnet files')
parser.add_argument(
    '--input', required=True, help='csv output from virnet')
parser.add_argument(
    '--output', required=True, help='Where to save the positive contig list')
parser.add_argument(
    '--filter', default=0.5, type=float, help='p value cutoff')
args = parser.parse_args()


# load csv into panda frame
df = pd.read_csv(args.input)
# split description to get "pure" contig names
df[['contig_name','hash']] = df.ID.str.split(",", expand=True)
# drop unneccesary columns
df=df.drop(columns=['ID', 'DESC', 'hash','result']).drop(df.columns[0], axis=1)
# calculate median
df = df.groupby("contig_name").median()
# filter by min median
df = df[df['score'] > args.filter]

with open(args.output, 'w+') as out:
  for row in df.index: 
    out.write(row + '\n')




