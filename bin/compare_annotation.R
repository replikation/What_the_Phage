#!/usr/bin/env Rscript
library(geneviewer)
library(htmlwidgets)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("GenomicRanges")
# BiocManager::install("Biostrings")
library(Biostrings)

################################################
################# inputs #######################
################################################
# get inputs
args <- commandArgs(trailingOnly = TRUE)
fasta_file <- args[1]
pharokka_bed <- args[2]
phabox_bed <- args[3]
genomad_bed <- args[4]
prodigal_bed <- args[5]
checkv <- args[6]
completeness_threshold <- as.numeric(args[7])


# 1fasta 2pharokka 3phabox2 4genomad 5prodigal 6checkv 7completeness
### also read fasta file for genome lenght calculation



# strand information available for genomad, phabox, and pharokka

genomad <- read.delim(
  genomad_bed,
  header = FALSE,
  sep = "\t",
  col.names = c("contig", "start", "end", "annotation", "strand")
)

# Import all_pos_phage_phabox2.bed
phabox2 <- read.delim(
  phabox_bed,
  header = FALSE,
  sep = "\t",
  col.names = c("contig", "start", "end", "annotation", "strand")
)

# Import all_pos_phage_pharokka.bed
pharokka <- read.delim(
  pharokka_bed,
  header = FALSE,
  sep = "\t",
  col.names = c("contig", "start", "end", "annotation", "strand")
)

# Import the fourth file mentioned in the second part of the request
prodigal <- read.delim(
  prodigal_bed,
  header = FALSE,
  sep = "\t",
  col.names = c("contig", "start", "end", "annotation")
)



fasta_sequence <- readDNAStringSet(fasta_file)
fasta_lengths <- width(fasta_sequence)
contig_name <- names(fasta_sequence)
fasta_lengths_df <- data.frame(
  contig = contig_name,
  contig_length = fasta_lengths
)
fasta_lengths_df <- fasta_lengths_df %>%
  mutate(contig = str_replace_all(contig, "\\.", "_"))




# filter contigs based on completeness of checkV
df_checkv <- read_tsv(checkv, show_col_types = FALSE)

high_completeness_contigs <- df_checkv %>%
  # Filter rows where completeness is greater than the defined threshold
  filter(completeness >= completeness_threshold) %>%
  # Select only the contig_id column
  select(contig_id) %>%
  # Convert the result to a simple vector of names (optional, but often useful)
  pull()

################################################
################# data analysis ################
################################################
if (nrow(genomad) > 0) {
  genomad$tool <- "genomad"
}

# Check if phabox2 is not empty
if (nrow(phabox2) > 0) {
  phabox2$tool <- "phabox2"
}

# Check if pharokka is not empty
if (nrow(pharokka) > 0) {
  pharokka$tool <- "pharokka"
}

# Check if prodigal is not empty
if (nrow(prodigal) > 0) {
  prodigal$strand <- "+"
  prodigal$tool <- "prodigal" # Adding toolname for the fourth file too
  
}

# genomad$tool <- "genomad"
# phabox2$tool <- "phabox2"
# pharokka$tool <- "pharokka"
# prodigal$tool <- "prodigal" # Adding toolname for the fourth file too

# 3. Combine all dataframes into a single dataframe
phage_combined <- rbind(
  genomad,
  phabox2,
  pharokka,
  prodigal 
)

## potentially filter dataframe for important genes (Capsid, head tail fiber sheath holin Endolysins Spanins Portal protein depolymerases Integrase Terminase  toxins Effector )
keywords <- "Capsid|head|tail|sheath|holin|endolysin|spanin|portal|depolymerase|integrase|terminase|toxin|effector|hypothetical protein"

phage_combined <- phage_combined %>%
mutate(
  gene_of_interest = case_when(
    # If annotation is NA, the new column is NA
    is.na(annotation) ~ NA_character_,
    
    # If annotation contains any of the keywords (case-insensitive check)
    str_detect(annotation, regex(keywords, ignore_case = TRUE)) ~ str_extract(
      annotation, 
      # Extract the matched keyword (Terminase or hypothetical protein in this case)
      regex(keywords, ignore_case = TRUE)
    ),
    
    # If none of the above conditions are met (i.e., annotation is not NA 
    # but does not contain a keyword)
    TRUE ~ "other"
  )
)

phage_combined <- phage_combined %>%
  filter(contig %in% high_completeness_contigs)



# 4. Create new dataframes based on contig
# The names of the list elements will be the contig IDs.
contig_dataframes_list <- split(phage_combined, phage_combined$contig)






colors <- list(  "capsid" = "#9D84AB",
                 "head" = "#E8A9B4",
                 "tail" = "#C4DFE5",
                 "fiber" = "#F5D0D0",
                 "sheath" = "#FFF2D9",
                 "holin" = "#99DEB9",
                 "endolysin" = "#6CABA5",
                 "spanin" = "#B1E5F2",
                 "portal" = "#FFD187",
                 "depolymerase" = "#C5C5E4",
                 "integrase" = "#F9A99E",
                 "terminase" = "#A0D5B5",
                 "toxin" = "#D9B89B",
                 "effector" = "#A4A8A3",
                 "tail" = "#FFC697",
                 "hypothetical protein"= "#D3D3D3",
                 "other" = "#B2B2C0")

# Loop through the list of contig dataframes
for (contig_name in names(contig_dataframes_list)) {
  
  # Get the dataframe for the current contig
  contig_to_view <- contig_dataframes_list[[contig_name]]
  
  # Find the length of the current contig
  contig_length <- fasta_lengths_df %>%
    filter(contig == contig_name) %>%
    pull(contig_length)


plot <- GC_chart(contig_to_view,
         group = "gene_of_interest",    # Now group by tool within that contig
         cluster = "tool",  # Separate tracks by tool
         height = "800px") %>%
  GC_tooltip(
    formatter = "<b>{annotation}</b><br><b>Start:</b> {start}<br><b>End:</b> {end}",
    show = TRUE,
  ) %>%
  GC_genes(
    marker = "boxarrow",
    marker_size = "small"
  )%>%
  GC_clusterLabel(title = unique(contig_to_view$tool)) %>% 

  GC_scale(axis_type = "range",
             start = 0, 
             end = contig_length ) %>%
  GC_cluster(prevent_gene_overlap = TRUE, overlap_spacing = 5) %>%
  GC_legend(
    group = "gene_of_interest",
    legendTextOptions = list(fontSize = "12px"),
    order = c(setdiff(sort(contig_to_view$gene_of_interest), "other"), "other")
    
  )  %>%
  GC_title(
  title = contig_name,
  show = TRUE
) %>%
  GC_color(customColors = colors)


# Define the output file name
output_filename <- paste0(contig_name, "_annotation_comparison.html")

# Save the plot
# NOTE: You need to make sure the htmlwidgets library is loaded for saveWidget
# library(htmlwidgets)
htmlwidgets::saveWidget(plot, output_filename, selfcontained = TRUE)

print(plot)
}
## save a plot plot a single contig
# htmlwidgets::saveWidget(plot, "test_plot.html", selfcontained = TRUE)



################################################
################# statistics #######################
################################################


# df_processed <- phage_combined %>%
#   # Calculate the length of each annotated feature
#   mutate(length = end - start + 1) %>%
  
#   # Create the 'is_annotated' column
#   mutate(
#     is_annotated = case_when(
#       # Condition 1: Annotation is an actual NA value (missing annotation) -> FALSE
#       is.na(annotation) ~ FALSE,
      
#       # Condition 2: Annotation contains "hypothetical protein" (case-insensitive) -> FALSE
#       # This handles common variants like "Hypothetical protein" or "hypothetical_protein"
#       str_detect(annotation, regex("hypothetical protein", ignore_case = TRUE)) ~ FALSE,
      
#       # Default: Any other annotation is considered a "true" annotation -> TRUE
#       TRUE ~ TRUE
#     )
#   )

# coverage_df <- df_processed %>%
#   # 3. Join with corrected contig lengths
#   left_join(fasta_lengths_df, by = "contig") %>%
  
#   # 4. Group and Summarize
#   group_by(contig, tool, is_annotated, contig_length) %>%
#   summarise(
#     total_covered_length = sum(length),
#     .groups = "drop"
#   ) %>%
  
#   # 5. Calculate the percentage of coverage
#   mutate(
#     coverage_percentage = (total_covered_length / contig_length) * 100
#   ) %>%
  
#   # 6. Reorder and RENAME the annotation type for clarity (THE REQUESTED CHANGE)
#   mutate(
#     Annotation_Type = case_when(
#       is_annotated == FALSE ~ "hypothetical protein or NA",
#       is_annotated == TRUE ~ "annotated protein"
#     )
#   ) %>%
#   # 7. Add this block to convert to a factor and set the order!
#   mutate(
#     Annotation_Type = factor(
#       Annotation_Type,
#       levels = c(
#         "annotated protein",         # First level (will be at the bottom of the stack)
#         "hypothetical protein or NA" # Second level (will be at the top of the stack)
#       )
#     )
#   ) %>%
  
#   # Final select and arrangement
#   select(
#     contig,
#     tool,
#     Annotation_Type, # Now using the modified factor column
#     total_covered_length,
#     contig_length,
#     coverage_percentage
#   ) %>%
#   # Change the final arrange to prioritize the factor order
#   arrange(contig, tool, Annotation_Type)

# # Print the final result dataframe
# print(coverage_df)


# ################################################
# ################# plot #######################
# ################################################


# p <- ggplot(
#   data = coverage_df,
#   aes(
#     # X-axis is Contig
#     x = tool,
#     # Y-axis is Coverage Percentage
#     y = coverage_percentage,
#     # Fill/stacking color is Annotation Type
#     fill = Annotation_Type,
#     # Crucially, group the bars by the Tool
#     group = contig
#   )
# ) +
#   # Use geom_col for bar plots.
#   # The 'position = "stack"' here is the default and stacks the fill.
#   # The 'position = position_dodge(width = 0.9)' makes the bars for each tool cluster together.
#   geom_bar(position="stack", stat="identity") +
#   facet_wrap(~ contig ) +
#   # Add labels and titles
#   labs(
#     title = "Annotation Coverage by Contig and Tool",
#     y = "Coverage Percentage (%)",
#     fill = "Annotation Type"
#   ) +
#   # Improve the theme
#   theme_minimal() +
#   theme(
#     axis.text.x = element_text(angle = 45, hjust = 1), # Rotate X-axis labels
#     plot.title = element_text(face = "bold", hjust = 0.5),
#     legend.position = "bottom"
#   )


# # Print the plot
# print(p)
# htmlwidgets::saveWidget(p, "annotation_statistics.html", selfcontained = TRUE)