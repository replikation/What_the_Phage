#!/bin/bash


# Usage: ./tsv2bed_custom.sh <input_file.tsv> <output_file.bed>

# Check if both required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing arguments." >&2
    echo "Usage: $0 <input_file.tsv> <output_file.bed>" >&2
    exit 1
fi

INPUT_TSV="$1"
OUTPUT_BED="$2"

# The core conversion logic using awk
# -F'\t': Sets input field separator to tab
# OFS='\t': Sets output field separator to tab
awk -F'\t' 'BEGIN {OFS="\t"} {
    # Skip the header line (Check if NR is 1)
    if (NR == 1) {
        next
    }

    # 1. Genome (Chrom): $1 (gene) with trimming
    # The 'gene' field ($1) is like 'pos_phage_0_1'. 
    # We remove the last underscore and everything after it, resulting in 'pos_phage_0'.
    genome_name = $1
    sub(/_[^_]+$/, "", genome_name)
    
    # 2. chromStart: $2 - 1 (Start - 1 for 0-based conversion)
    start_bed = $2 - 1
    
    # 3. chromEnd: $3 (End)
    end_bed = $3
    
    # 4. name: $20 (annotation_description)
    annotation = $20

    # Print the four fields in BED format: genome, start, end, annotation
    print genome_name, start_bed, end_bed, annotation
}' "$INPUT_TSV" > "$OUTPUT_BED"