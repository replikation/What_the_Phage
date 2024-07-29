#!/usr/bin/env python
import os
import re
import argparse

## python decision_plotting_prepare.py --input read_until_FAP76673_e0481cad.csv --output first_steps.csv --chunksize 50

parser = argparse.ArgumentParser(description='read until parser for decision_plotting_prepare')
parser.add_argument(
    '--input', required=True, help='choose inputfile')
parser.add_argument(
    '--contigs_to_extract', required=True, help='choose inputfile')


args = parser.parse_args()

# Define the input file and output extension
input_file = args.input
output_extension = '.gbk'
contigs_file = args.contigs_to_extract


def read_contigs_list(contigs_file):
    """Read the list of contigs to extract from the file."""
    with open(contigs_file, 'r') as file:
        contigs = [line.strip() for line in file if line.strip()]
    print(f"Contigs to extract: {contigs}")
    return contigs

def split_and_filter_file(input_file, output_extension, delimiter, contigs_to_extract):
    """Split the input file by delimiter and filter sections based on contigs to extract."""
    with open(input_file, 'r') as file:
        content = file.read()

    # Split the content based on the delimiter
    parts = content.split(delimiter)
    print(f"Number of parts after splitting: {len(parts)}")

    output_generated = False
    for part_index, part in enumerate(parts):
        print(f"\nProcessing part {part_index + 1}/{len(parts)}:")
        if part.strip() == "":
            continue  # Skip empty parts

          # Extract the ACCESSION line (e.g., ACCESSION   pos_phage_9)
        match = re.search(r'^ACCESSION\s+(\S+)', part, re.MULTILINE)
        if match:
            accession = match.group(1).strip()
            print(f"Found ACCESSION: '{accession}'")
            if accession in contigs_to_extract:
                output_file = f'{accession}{output_extension}'
                print(f"Writing to file: {output_file}")
                with open(output_file, 'w') as file:
                    file.write(part.strip() + '\n//\n')  # Append // to the end
                output_generated = True
            else:
                print(f"ACCESSION '{accession}' not in the contigs to extract: {contigs_to_extract}")
        else:
            print("ACCESSION line not found in part.")
    
    if not output_generated:
        print("No matching ACCESSION values found in the input file.")

    print("Processing complete.")

# Read contigs to extract from file
contigs_to_extract = read_contigs_list(contigs_file)

# Split and filter the input file
split_and_filter_file(input_file, output_extension, delimiter='//', contigs_to_extract=contigs_to_extract)
