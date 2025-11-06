#!/bin/bash


## Usage: ./phabox2_to_bed.sh <input.gff> <output.bed>

#!/bin/bash

# Script to convert a custom TSV file (1-based, inclusive) to BED4 
# (0-based, exclusive, with chrom, start, end, annotation).
# Usage: ./tsv2bed.sh <input_file.tsv> <output_file.bed>

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
    # Skip the header line (Check if $1 is 'Genome')
    if (NR == 1 && $1 == "Genome") {
        next
    }

    # Column Mapping:
    # 1. chrom: $1 (Genome)
    # 2. chromStart: $3 - 1 (Start - 1 for 0-based conversion)
    # 3. chromEnd: $4 (End)
    # 4. name: $7 (Annotation)

    # Print the four fields in BED format
    print $1, $3-1, $4, $7
}' "$INPUT_TSV" > "$OUTPUT_BED"