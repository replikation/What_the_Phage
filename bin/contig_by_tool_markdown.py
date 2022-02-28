#!/usr/bin/env python


#docker run --rm -it -v $PWD:/input nanozoo/template:3.8--21e23c9
#cd input/
#pip install pandas
#pip install numpy
#python

# import modules
import pandas as pd
import numpy as np
import csv
from collections import defaultdict
from tqdm import tqdm
import argparse  


## python python count_total_amount_of_bases_per_organism.py --idx_stats idx_stats_LSK109.tsv --coverage_stats LSK109_coverage_output.out  --kitname LSK109 --output LSK109_amount_of_bases.csv

parser = argparse.ArgumentParser(description='calculating bp of organism in a sample after minimapping')
parser.add_argument(
    '--overview_file', required=True, help='choose inputfile: overview_file.tsv')
parser.add_argument(
    '--output', required=True, help='Where to save the splitted csv for plotting')
# parser.add_argument(
#     '--chunk_size', required=True, help='size of basepair_chunks/segments to plot, eg 50 ')
args = parser.parse_args()


overview = args.overview_file

#overview = 'contig_tool_p-value_overview.tsv'
### fileInputs
df = pd.read_csv(overview, sep="\t")
## second field (p value over 0.5
df_cutoff = df[df.p_value > 0.5]
## how many tools per contig 
contig_by_tool2 = contig_by_tool = df_cutoff.groupby(['contig_name'])['toolname'].count().reset_index()
contig_by_tool2.columns = ['contig_name', 'tools_agree']
contig_by_tool2.to_csv('tools_agree.tsv', sep = '\t', index=False)

## conditions list
conditions = [
    (contig_by_tool2['tools_agree'] >= 12),
    (contig_by_tool2['tools_agree'] < 12) & (contig_by_tool2['tools_agree'] >= 9),
    (contig_by_tool2['tools_agree'] < 9) & (contig_by_tool2['tools_agree'] >= 6),
    (contig_by_tool2['tools_agree'] < 6) & (contig_by_tool2['tools_agree'] >= 3),
    (contig_by_tool2['tools_agree'] <3)
    ]
# create a list of the values we want to assign for each condition
values = ['14-12_tool_agreements', '11-9_tool_agreements', '8-6_tool_agreements', '5-3_tool_agreements', '2-0_tool_agreements']
# create a new column and use np.select to assign values to it using our lists as arguments
contig_by_tool2['contig_by_tool'] = np.select(conditions, values)

#contig_by_tool2.to_csv('contig_by_tool_category.tsv', sep = '\t', header=True, index=False)
contig_by_tool2.to_csv(args.output, header=True, index=False)




