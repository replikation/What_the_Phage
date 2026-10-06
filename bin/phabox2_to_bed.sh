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

    # Column Mapping (based on your TSV):
    # $1: Genome (chrom)
    # $2: ORF (used as name for better identification than $7)
    # $3: Start
    # $4: End
    # $5: Strand (1 or -1)
    # $7: Annotation (product)
    
    # chrom: $1 (Genome)
    chrom = $1
    
    # chromStart: $3 - 1 (Start - 1 for 0-based BED)
    start_bed = $3 - 1
    
    # chromEnd: $4 (End)
    end_bed = $4
    
    # name: Using $2 (ORF) for the name field
    name_bed = $2 
        
    # strand: Convert 1 -> +, -1 -> -
    strand_tsv = $5
    if (strand_tsv == "1") {
        strand_bed = "+"
    } else if (strand_tsv == "-1") {
        strand_bed = "-"
    } else {
        # Catch unexpected or missing values
        strand_bed = "." 
    }
    # name: Using $2 (ORF) for the name field
    annotation_bed = $7 
    # Print the six required fields for BED6 format:
    # chrom, chromStart, chromEnd, name, score, strand
    print chrom, start_bed, end_bed, annotation_bed, strand_bed
}' "$INPUT_TSV" > "$OUTPUT_BED"