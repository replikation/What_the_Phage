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

    # Your TSV fields:
    # $1: Genome, $2: ORF, $3: Start, $4: End, $5: Strand, $7: Annotation

    # 1. chrom: $1 (Genome)
    genome_name = $1
    sub(/_[^_]+$/, "", genome_name)
    
    # 2. chromStart: $2 - 1 (Start - 1 for 0-based conversion)
    start_bed = $2 - 1
    
    # 3. chromEnd: $4 (End)
    end_bed = $3
    # 4. name: $20 (annotation_description)
    annotation = $20

    # 6. strand: $5 (Strand) - Must convert 1 to '+', and -1 to '-'
    strand_tsv = $5
    if (strand_tsv == "1") {
        strand_bed = "+"
    } else if (strand_tsv == "-1") {
        strand_bed = "-"
    } else {
        # Handle cases where strand might be other values or blank
        strand_bed = "." 
    }

    # Print the six required fields for BED format:
    # chrom, chromStart, chromEnd, strand
    print genome_name, start_bed, end_bed, annotation, strand_bed
}' "$INPUT_TSV" > "$OUTPUT_BED"