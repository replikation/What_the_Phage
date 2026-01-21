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
################# waffle plot #######################
################################################
library(remotes)
library(waffle)

df_processed <- phage_combined %>%
  mutate(length = end - start + 1) %>%
  
# Create the granular 'Annotation_Type' column with three categories
# Create the simplified 'Annotation_Type' column with two primary categories
  mutate(
    Annotation_Type = case_when(
      # Condition 1 & 2 combined: NA (missing annotation) OR Hypothetical protein (case-insensitive)
      is.na(annotation) | str_detect(annotation, regex("hypothetical protein", ignore_case = TRUE)) ~ "low-confidence/missing",
      
      # Default: Any other annotation is considered a "true" annotation
      TRUE ~ "annotated protein"
    )
  )

# Calculate covered lengths for the three categories
category_coverage_df <- df_processed %>%
  # Join with contig length
  left_join(fasta_lengths_df, by = "contig") %>%
  # Group and Summarize
  group_by(contig, tool, Annotation_Type, contig_length) %>%
  summarise(
    total_covered_length = sum(length),
    .groups = "drop"
  )

# Calculate Total Covered Length per Tool and the Uncovered Portion
# simplistic sum (NOT overlap-aware)
total_covered_df <- category_coverage_df %>%
  group_by(contig, tool, contig_length) %>%
  summarise(
    total_covered_by_tool = sum(total_covered_length),
    .groups = "drop"
  )

# Calculate Uncovered Length and prepare it for merging
uncovered_df <- total_covered_df %>%
  mutate(
    Annotation_Type = "uncovered",
    # Calculate the uncovered length
    total_covered_length = contig_length - total_covered_by_tool
  ) %>%
  select(contig, tool, Annotation_Type, total_covered_length, contig_length)

# Combine all categories and calculate final percentages
final_coverage_df <- bind_rows(category_coverage_df, uncovered_df) %>%
  # Calculate the final percentage
  mutate(
    coverage_percentage = (total_covered_length / contig_length) * 100
  ) %>%
  # Handle potential negative 'uncovered' length (due to overlaps) by setting it to 0
  mutate(
    total_covered_length = pmax(0, total_covered_length),
    coverage_percentage = pmax(0, coverage_percentage)
  ) %>%
  # Final selection and ordering
  select(
    contig,
    tool,
    Annotation_Type,
    total_covered_length,
    contig_length,
    coverage_percentage
  ) %>%
  # Order the Annotation_Type for better readability
  arrange(contig, tool, desc(Annotation_Type)) %>%
  # Format percentage for cleaner output
  mutate(
    coverage_percentage = round(coverage_percentage, 2)
  )

# Print the final result dataframe
print(final_coverage_df)

# normalize t he waffleplot
waffle_data_normalized <- final_coverage_df %>%
  group_by(contig, tool) %>%
  # Convert raw lengths directly to proportions of 100
  mutate(n_tiles = as.integer(round((total_covered_length / contig_length) * 100))) %>%
  # Handle the "Uncovered" category as a "Filler" to ensure sum = 100
  mutate(n_tiles = if_else(Annotation_Type == "uncovered", 
                           100 - sum(n_tiles[Annotation_Type != "uncovered"]), 
                           n_tiles)) %>%
  ungroup()



# Define adjustable colors for the categories
waffle_colors <- c(
  "annotated protein"       = "#33d833ff",
  "low-confidence/missing" = "#f0ad4e",
  "uncovered"              = "#da615dff" 
)

# --- Per Contig Waffle Plots ---
for (current_contig in unique(waffle_data_normalized$contig)) {
  
  contig_waffle_data <- waffle_data_normalized %>%
    filter(contig == current_contig)
    
  plot_waffle <- contig_waffle_data %>%
    ggplot(aes(fill = Annotation_Type, values = n_tiles)) +
    geom_waffle(n_rows = 10, size = 0.33, color = "white", flip = TRUE) +
    facet_wrap(~ tool, ncol = 2) +
    labs(
      title = paste("Annotation Breakdown:", current_contig),
      fill = "Annotation Type"
    ) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.text = element_blank(),
      axis.title = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(hjust = 0.5, face = "bold")
    ) +
    scale_fill_manual(values = waffle_colors)
    
  ggsave(file=paste0(current_contig, "_waffle.svg"), plot=plot_waffle, width=10, height=8)
}

# --- Aggregated Waffle Summary (All Contigs) ---

# 1. Sum up lengths across ALL contigs per tool/category
waffle_summary <- final_coverage_df %>%
  group_by(tool, Annotation_Type) %>%
  summarise(total_length = sum(total_covered_length), .groups = "drop") %>%
  group_by(tool) %>%
  mutate(
    # Calculate percentage based on total length of all filtered contigs
    total_tool_length = sum(total_length),
    waffle_percentage = (total_length / total_tool_length) * 100,
    n_tiles = round(waffle_percentage)
  ) %>%
  ungroup()

# 2. Create the Plot
plot_waffle_summary <- waffle_summary %>%
  ggplot(aes(fill = Annotation_Type, values = n_tiles)) +
  geom_waffle(n_rows = 10, size = 0.33, color = "white", flip = TRUE) +
  facet_wrap(~ tool, ncol = 2) +
  labs(
    title = "Global Annotation Summary (All Filtered Contigs)",
    subtitle = paste("Summary of contigs with completeness >=", completeness_threshold, "%"),
    fill = "Annotation Type"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  ) +
  scale_fill_manual(values = waffle_colors)

# 3. Save the summary plot
print(plot_waffle_summary)
ggsave(file="annotation_summary_plot.svg", plot=plot_waffle_summary, width=10, height=8)
