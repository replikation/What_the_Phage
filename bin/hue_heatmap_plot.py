#!/usr/bin/env python

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import argparse

## python heatmap.py --input *.tsv --output heatmap.pdf

## get input files and provide an outputfile
parser = argparse.ArgumentParser(description = 'creation of heatmap')
parser.add_argument('--input',nargs='*', required = True, help = 'tsv from phagelist')
parser.add_argument('--output', required=True)
args = parser.parse_args()


tool_name_list = list(args.input)
# erstellst dictionary und liest csv files
## create  empty dfs dictionary, df dataframe
extended_df_of_all_tools = []
tool_name_list_kopie = []
dfs = {}

##  'print' all dictonarys 
for tools in tool_name_list:
  df = pd.read_csv(tools, sep ='\t|/t', engine ='python',  header=None) #sep ='\t|/t'
  sep = '_'
  toolname = tools.split(sep, 1)[0] 
  df = df.sort_values([0],ignore_index=True)
  df['toolname'] = toolname
  df.columns = ['name', 'value','toolname']
  extended_df_of_all_tools.append(df) 
## combine all tool outputs into one big list of contigs toolname and pvalue
extended_df_of_all_tools = pd.concat(extended_df_of_all_tools)

size_h = df['toolname'].nunique()
size_w = df['name'].nunique()

sns.set(rc={'figure.figsize':(size_w * 3,size_h * 3)})

final_heatmap = extended_df_of_all_tools.pivot('name', "toolname", 'value')

if args.output:
  #to save the plot in a png as figure
  sns.heatmap(final_heatmap, annot=True,cmap="Blues").figure.savefig(args.output)