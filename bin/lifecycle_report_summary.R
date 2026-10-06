#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
output <- if(length(args) > 0) args[1] else "summary.tsv"

bacphlip_files <- list.files(pattern = "_lifecycle_bacphlip\\.tsv$")
phabox2_files  <- list.files(pattern = "_phatyp_prediction_lifecycle_phabox2\\.tsv$")

read_bacphlip <- function(f) {
  d <- read.table(f, sep = "\t", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
  colnames(d)[1] <- "contig"
  d$contig <- as.character(d$contig)
  return(d)
}

read_phabox2 <- function(f) {
  d <- read.table(f, sep = "\t", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
  d$contig <- as.character(d$Accession)
  d$TYPE   <- tolower(as.character(d$TYPE))
  return(d)
}

bacphlip_df <- NULL
if (length(bacphlip_files) > 0 && file.info(bacphlip_files[1])$size > 0) {
  bacphlip_df <- read_bacphlip(bacphlip_files[1])
  bacphlip_df <- bacphlip_df[, c("contig", "Virulent", "Temperate")]
  bacphlip_df$bacphlip_prediction <- ifelse(
    bacphlip_df$Virulent >= bacphlip_df$Temperate, "virulent", "temperate"
  )
}

phabox2_df <- NULL
if (length(phabox2_files) > 0 && file.info(phabox2_files[1])$size > 0) {
  phabox2_df <- read_phabox2(phabox2_files[1])
  phabox2_df <- phabox2_df[, c("contig", "Length", "TYPE", "PhaTYPScore")]
}

if (is.null(bacphlip_df)) {
  bacphlip_df <- data.frame(
    contig = character(), Virulent = numeric(), Temperate = numeric(),
    bacphlip_prediction = character()
  )
}
if (is.null(phabox2_df)) {
  phabox2_df <- data.frame(
    contig = character(), Length = numeric(), TYPE = character(),
    PhaTYPScore = numeric()
  )
}

final_df <- merge(bacphlip_df, phabox2_df, by = "contig", all = TRUE)
final_df$Consensus <- ifelse(
  is.na(final_df$bacphlip_prediction), final_df$TYPE,
  ifelse(is.na(final_df$TYPE), final_df$bacphlip_prediction,
         ifelse(final_df$bacphlip_prediction == final_df$TYPE,
                final_df$TYPE, "disagree"))
)
final_df <- final_df[, c(
  "contig", "Length", "Virulent", "Temperate", "bacphlip_prediction",
  "TYPE", "PhaTYPScore", "Consensus"
)]
colnames(final_df) <- c(
  "Contig", "Length", "bacphlip_Virulent", "bacphlip_Temperate",
  "bacphlip_prediction", "phatyp_TYPE", "phatyp_PhaTYPScore", "Consensus"
)

write.table(final_df, output, sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
