#!/usr/bin/env python3
import json
import csv
import sys
import os
import argparse
def main():
    parser = argparse.ArgumentParser(description='Consolidate TSV/CSV files into a single JSON.')
    parser.add_argument('--output', required=True, help='Output JSON file path')
    parser.add_argument('--name', required=True, help='Sample/Report name')
    parser.add_argument('files', nargs='+', help='Input TSV/CSV files to process')
    
    args = parser.parse_args()
    
    result = {
        "sample": args.name,
        "files": {}
    }
    
    for filepath in args.files:
        filename = os.path.basename(filepath)
        
        # Determine delimiter based on extension
        if filename.endswith('.tsv'):
            delimiter = '\t'
        elif filename.endswith('.csv'):
            delimiter = ','
        else:
            print(f"Skipping non-spreadsheet file: {filename}")
            continue
            
        try:
            if not os.path.exists(filepath) or os.path.getsize(filepath) == 0:
                result["files"][filename] = []
                continue
                
            with open(filepath, 'r', encoding='utf-8') as f:
                reader = csv.reader(f, delimiter=delimiter)
                rows = list(reader)
                result["files"][filename] = rows
        except Exception as e:
            print(f"Error reading {filename}: {e}")
            
    # Write the result
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2)
if __name__ == "__main__":
    main()