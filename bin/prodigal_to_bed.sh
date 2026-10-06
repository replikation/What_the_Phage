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
    # Assuming no header based on provided data, skip empty lines just in case
    if ($1 == "") {
        next
    }

    # 1. Genome (Chrom): $2
    genome = $2
    
    # 2. chromStart: $3 - 1 (Start - 1 for 0-based conversion)
    start_bed = $3 - 1
    
    # 3. chromEnd: $4 (End)
    end_bed = $4
    
    # 4. Annotation (Name): $1, with end tag removed
    annotation = $1
    # Remove the tag starting from "_[n=" until the end of the string
    sub(/_\[n=.*$/, "", annotation)

    # Print the four fields in the desired BED format: Genome, start, end, annotation
    print genome, start_bed, end_bed, annotation
}' "$INPUT_TSV" > "$OUTPUT_BED"