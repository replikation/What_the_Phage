#!/usr/bin/env Rscript
library(chromoMap)
library(ggplot2)
library(plotly)

args <- commandArgs(trailingOnly = TRUE) 
in_chromosome <- args[1]
in_annotation <- args[2]
type <- args[3] #type info small or large
count <- args[4]

# own input
df_in_chromosome <- read.table(in_chromosome, sep="\t", header = TRUE)
df_in_annotation <- read.table(in_annotation, sep="\t", header = TRUE)
file_name <- paste0("sample_overview_", type, ".html")

sizeh <- ( nrow(df_in_chromosome <- read.table(in_chromosome, sep="\t", header = TRUE)) * 80 )

if (count == 4) {  

p <-  chromoMap(in_chromosome,in_annotation,
            data_based_color_map = T,
            data_type = "categorical",
            segment_annotation = T,
            data_colors = list(c("red", "lightblue", "orange", "green")),
            labels=F,
            legend=T, lg_x = 300,
            left_margin = 340, canvas_width = 1500, canvas_height = sizeh, chr_length = 12, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), file_name)
}
if (count == 3) { 
p <-  chromoMap(in_chromosome,in_annotation,
 data_based_color_map = T,
            data_type = "categorical",
            segment_annotation = T,
            data_colors = list(c("lightblue", "orange", "red")),
            labels=F,
            legend=T, lg_x = 300,
            left_margin = 340, canvas_width = 1500, canvas_height = sizeh, chr_length = 12, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), file_name)
}
if (count == 2) { 
p <-  chromoMap(in_chromosome,in_annotation,
  data_based_color_map = T,
            data_type = "categorical",
            segment_annotation = T, 
            data_colors = list(c("lightblue", "orange")),
            labels=F,
            legend=T, lg_x = 300,
            left_margin = 340, canvas_width = 1500, canvas_height = sizeh, chr_length = 12, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), file_name)
}
if (count == 1) { 
p <-  chromoMap(in_chromosome,in_annotation,
            data_type = "categorical",
            segment_annotation = T,
            labels=F,
            legend=T, lg_x = 300,
            anno_col = c("lightblue"),
            left_margin = 340, canvas_width = 1400, canvas_height = sizeh, chr_length = 8, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), file_name)
}