#!/usr/bin/env Rscript

####

# phage plasmid plot


        #  if (!require("BiocManager", quietly = TRUE))
        #    install.packages("BiocManager")
        #  BiocManager::install("ComplexHeatmap")

        # # split fasta into single contig files
        # if (!requireNamespace("BiocManager", quietly = TRUE))
        #     install.packages("BiocManager")
        #  BiocManager::install("Biostrings")


# call my librarys
library("ComplexHeatmap")
library("circlize")
library("dplyr")
library("grid")
library("gridBase")
library("ggplot2")
library("Biostrings")


# 9.2 Customize chromosome track https://jokergoo.github.io/circlize_book/book/initialize-genomic-plot.html#customize-chromosome-track

# Plot for Phabox 2 annotation output
# Genome	ORF	Start	End	Strand	GC	Annotation	pident	coverage
# pos.phage.0	pos.phage.0_1	265	537	1	0.403	hypothetical protein	96.7	1
# pos.phage.0	pos.phage.0_2	624	986	1	0.43	membrane protein	99.2	1
# pos.phage.0	pos.phage.0_3	1214	1474	1	0.421	hypothetical protein	100	1


# get inputs
args <- commandArgs(trailingOnly = TRUE)

# import input files
fasta_file <- args[1]
phabox2_annotation <- args[2]  # annotation file from phabox2
phage_df <- read.table(phabox2_annotation, sep='\t', header=TRUE)



# ---------------------------------read phage annotation file from phabox ------------------------------#

# df <- read.delim("single_phage_phabox_annotation.tsv", sep = "\t", header = TRUE)
# phage_df <- df
# fasta_file <- "pos.phage.0.fasta"


# get length of fasta, name of fasta and extract only the corresponding contigs from the bedfile
fasta_sequence <- readDNAStringSet(fasta_file)
fasta_lengths <- width(fasta_sequence)
contig_name <- names(fasta_sequence)
phage_df <- phage_df[phage_df$Genome %in% contig_name, ]

# ---------------------------------subsample to strand specific and bedfile ------------------------------#

# make columns numeric for genome.label
phage_df$Start  <- as.numeric(phage_df$Start)
phage_df$End <- as.numeric(phage_df$End)

genomic_label_df_all <- phage_df[, c("Genome", "Start", "End", "Annotation")]
genomic_label_df_all <- subset(genomic_label_df_all, Annotation != "hypothetical protein")

# filter for strand 1, make 4 column bedfile and remove hypothetical protein
strand_pos <- subset(phage_df, Strand == 1)
genomic_label_df_pos_strand <- strand_pos[, c("Genome", "Start", "End", "Annotation")]
genomic_label_df_pos_strand <- subset(genomic_label_df_pos_strand, Annotation != "hypothetical protein")

# filter for strand -1, make 4 column bedfile and remove hypothetical protein
strand_neg <- subset(phage_df, Strand == -1)
genomic_label_df_neg_strand <- strand_neg[, c("Genome", "Start", "End", "Annotation")]
genomic_label_df_neg_strand <- subset(genomic_label_df_neg_strand, Annotation != "hypothetical protein")



# ---------------------------------filter genes into groups & creating color scheme for genes ------------------------------#
# classification of genes

structural <- c("fiber", "tail", "capsid", "baseplate", "head", "spike", "sheath")
modification <- c("DNA", "Methyltransferase", "tRNA", "exonuclease", "ligase", "transposase")
lysis <- c("holin", "hydrolase", "endolysin", "depolymerase")
packaging <- c("terminase", "portal protein")
# categorize phage annotations
# 1,2,3,4, collapse | is transforming it to 1|2|3|4 -- so grep l can search list like grep 
genomic_label_df_all <- genomic_label_df_all %>%
  mutate(Type = case_when(
    grepl(paste(structural, collapse = "|"), Annotation, ignore.case = TRUE) ~ "structural",
    grepl(paste(modification, collapse = "|"), Annotation, ignore.case = TRUE) ~ "modification" ,
    grepl(paste(lysis, collapse = "|"), Annotation, ignore.case = TRUE) ~ "lysis" ,
    grepl(paste(packaging, collapse = "|"), Annotation, ignore.case = TRUE) ~ "packaging" ,
    TRUE ~ "Other"
  ))

# colours for classified of genes
type_colors <- c(
  structural = "#FF5A5F",
  modification = "#087E8B",
  lysis = "#EFA00B",
  packaging = "royalblue",
  Other = "gray60"
)

genomic_label_df_all$LabelColor <- type_colors[match(genomic_label_df_all$Type, names(type_colors))]


# ---------------------------------set a contig to plot ------------------------------#

# get contigname (so genomic label is working)
# contig_name <- unique(phage_df[[1]]) # error handling missing for when i have multiple contigs by accident

# ---------------------------------Plotting ------------------------------#
png(paste(contig_name, "_map.png", sep=""))


plot.new()
# create a legend
circle_size = unit(1, "snpc") # snpc unit gives you a square region

pushViewport(viewport(x = 0, y = 0.5, width = circle_size, height = circle_size,
                      just = c("left", "center")))
par(omi = gridOMI(), new = TRUE)

lgd_points <- Legend(at = c("Structural genes", "Modification genes", "Lysis genes", "Packaging genes","Other"),
                     type = "points",
                     legend_gp = gpar(col = c("#FF5A5F", "#087E8B", "#EFA00B", "royalblue", "gray60")),
                     title = "Gene Categories")
lgd_combined <- packLegend(lgd_points)
# ---------------------------------circular plot ------------------------------#


# initialize Plot
circos.par(start.degree = 90, cell.padding = c(0.02, 0, 0.02, 0),gap.after = 13)
circos.initialize(
  factors = contig_name,
  xlim = c(0, fasta_lengths)  ## potential error?
)
# Genomic labels  col = as.numeric(factor(phage_df[[10]])), line_col = as.numeric(factor(phage_df[[10]]))
# cex- size of lable
circos.genomicLabels(genomic_label_df_all, labels.column = 4, side = "outside", cex = 0.8, labels_height = mm_h(5) ,connection_height= 0.1, col = genomic_label_df_all$LabelColor, line_col = genomic_label_df_all$LabelColor )

# Track for Strand 1
circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
  df_pos <- subset(phage_df, Strand == 1)
  for (i in seq_len(nrow(df_pos))) {
    col <- ifelse(df_pos$Annotation[i] == "hypothetical protein", "#613F75", "#EF798A")
    circos.arrow(df_pos$Start[i], df_pos$End[i],
                 arrow.head.length = cm_x(0.1),
                 arrow.head.width = CELL_META$yrange * 0.6,
                 col = col)
  
    }

  circos.yaxis(side = "left",
               at = 0.5,
               labels = "Strand 1",
               labels.cex = 0.6,
               sector.index = CELL_META$sector.index,
               track.index = CELL_META$track.index)
  
}, track.height = 0.1, bg.border = NA)

# Track for Strand -1
circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
  df <- subset(phage_df, Strand == -1)
  for (i in seq_len(nrow(df))) {
    col <- ifelse(df$Annotation[i] == "hypothetical protein", "#613F75", "#EF798A")
    circos.arrow(df$End[i], df$Start[i],
                 arrow.head.length = cm_x(0.1),
                 arrow.head.width = CELL_META$yrange * 0.6,
                 col = col)#,
                 #tail = "point")  # reverse strand styling
  }
  circos.yaxis(side = "left",
               at = 0.5,
               labels = "Strand -1",
               labels.cex = 0.6,
               sector.index = CELL_META$sector.index,
               track.index = CELL_META$track.index)

  
}, track.height = 0.1, bg.border = NA)


circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
  circos.axis(
    h = "bottom",
    major.at = seq(0, max(phage_df$End), by = 5000),
    labels.cex = 0.65,
    direction = "inside",
    labels.facing = "clockwise"
  )

}, track.height = 0.05, bg.border = NA)


circos.clear()



upViewport()

draw(lgd_combined, x = unit(4, "mm"), y = unit(4, "mm"), just = c("left", "bottom"))

dev.off()
