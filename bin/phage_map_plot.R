# phage plasmid plot

library("circlize")
library("dplyr")


# 9.2 Customize chromosome track https://jokergoo.github.io/circlize_book/book/initialize-genomic-plot.html#customize-chromosome-track
df <- read.delim("single_phage_annotation.tsv", sep = "\t", header = TRUE)



------------------testing----------------------------------------

df <- read.delim("single_phage_annotation.tsv", sep = "\t", header = TRUE)
# make bedformat
df_subset <- df[, c("Genome", "Start", "End", "Annotation")]
colnames(df_subset) <- c("chr", "start", "end", "value1")
df_subset$start <- as.numeric(df_subset$start)
df_subset$end <- as.numeric(df_subset$end)

circos.clear()
circos.par("track.height" = 0.5)

# Define the genome size (e.g., max end position)
genome_length <- max(df_subset$end)

# Initialize with one sector (the plasmid)
circos.initialize(factors = "pos.phage.0", xlim = c(0, genome_length))
# 
circos.trackPlotRegion(
  ylim = c(0, 1),
  panel.fun = function(x, y) {
    for (i in 1:nrow(df_subset)) {
      circos.rect(
        xleft = df_subset$start[i],
        xright = df_subset$end[i],
        ybottom = 0,
        ytop = 0.5,
        col = ifelse(df_subset$value1[i] == "hypothetical protein", "#66c2a5", "#fc8d62"),
        border = "black"
      )


    }
  },
  bg.border = NA
)


circos.genomicLabels(df_subset, labels.column = 4, side = "outside")
# circos.genomicLabels(df_subset, labels.column = 4, side = "outside", col = as.numeric(factor(df_subset[[1]])), line_col = as.numeric(factor(df_subset[[1]])))


circos.axis(h = "top", labels.cex = 0.6)
circos.clear()
