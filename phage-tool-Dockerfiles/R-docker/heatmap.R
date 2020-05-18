#!/usr/bin/env Rscript
library(reshape2)
library(gridExtra)
library(grid)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(ggthemes)

#heatmap with barplot
# https://stackoverflow.com/questions/21146153/r-heatmap-combined-with-barplot

args <- commandArgs(trailingOnly = TRUE) 
filein <- args[1]

# own input
df <- read.table(filein, sep=",", header = TRUE)
df <- read.table("summary.csv", sep=",", header = TRUE)
# convert
df.melted <- melt(df, id.vars=c("x.values"))
# add factor
g <- sapply(df.melted, is.integer)
df.melted[g] <- lapply(df.melted[g], as.factor)


hm <- ggplot(df.melted, aes(y=variable, x=factor(x.values), fill=value)) +
  geom_tile(color="white", size=0.5) + 
  labs(x="phage identification tool", y="contig name") +
  theme_hc() +
  theme(axis.text.x=element_blank()) +
  theme(legend.position="none") +
  theme(axis.text.x=element_text(angle = 270, vjust=0.5, hjust = 0)) +
  scale_fill_manual(values=c("#eaeaea", "#209ad6")) 

pdf("phage-distribution.pdf") 
hm
dev.off() 

