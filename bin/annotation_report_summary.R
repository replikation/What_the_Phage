#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
output <- if(length(args) > 0) args[1] else "summary.tsv"

files <- list.files(pattern = "\\.bed$")
# Final columns to keep
final_cols <- c("chrom", "start", "end", "gene_name", "strand", "tool")

df_list <- lapply(files, function(f) {
  if (file.info(f)$size == 0) return(NULL)
  
  d <- read.table(f, sep = "\t", header = FALSE, stringsAsFactors = FALSE)
  
  names <- c("chrom", "start", "end", "gene_name", "strand")
  colnames(d) <- names[1:ncol(d)]
  
  # Add tool column
  d$tool <- gsub(".*_([^_]+)\\.bed$", "\\1", f)
  
  # Ensure all final columns exist (add NA if missing)
  for(c in setdiff(final_cols, colnames(d))) d[[c]] <- NA
  
  # Select only requested columns
  return(d[, final_cols])
})

df_list <- df_list[!sapply(df_list, is.null)]

if (length(df_list) > 0) {
  final_df <- do.call(rbind, df_list)
  write.table(final_df, output, sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
} else {
  empty_df <- setNames(data.frame(matrix(ncol = length(final_cols), nrow = 0)), final_cols)
  write.table(empty_df, output, sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
}