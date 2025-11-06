#!/bin/bash


## Usage: ./pharokka_to_bed.sh <input.gff> <output.bed>

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing arguments." >&2
    echo "Usage: $0 <input_file.gff> <output_file.bed>" >&2
    exit 1
fi

INPUT_GFF="$1"
OUTPUT_BED="$2"

awk -F'\t' 'BEGIN {OFS="\t"} {
    # 1. Stop processing if the ##FASTA line is reached
    if ($1 == "##FASTA") {
        exit
    }
    
    # 2. Skip comment/header lines (usually start with a single '#')
    if ($1 ~ /^#/) {
        next
    }
    
    # 1. chrom (Seqname)
    chrom = $1
    
    # 2. chromStart (1-based GFF start minus 1 for 0-based BED)
    start = $4
    
    # 3. chromEnd (1-based GFF end is used as 0-based exclusive BED end)
    end = $5
    
   # 4. Extract Name/ID from the ninth field ($9)
    gene_name = ""

    #  find 'product='
    if (match($9, /product=[^;]+/)) {
        match_str = substr($9, RSTART, RLENGTH)
        sub(/^product=/, "", match_str)
        gene_name = match_str
    }
    # If 'product=' was not found, try to find 'ID='
    else if (match($9, /ID=[^;]+/)) {
        match_str = substr($9, RSTART, RLENGTH)
        sub(/^ID=/, "", match_str)
        gene_name = match_str
    }


    print chrom, start-1, end, gene_name
}' "$INPUT_GFF" > "$OUTPUT_BED"