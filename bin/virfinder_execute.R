#!/usr/bin/env Rscript
library(VirFinder)
 
args <- commandArgs(trailingOnly = TRUE) 
filein <- args[1] 
 
            
predResult <- VF.pred(filein) 
options(width=10000) 
results <- predResult[order(predResult$pvalue),]

sink("results.txt")
print(results)
sink()