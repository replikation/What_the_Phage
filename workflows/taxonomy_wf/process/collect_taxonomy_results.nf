process collect_taxonomy_results {
    publishDir "${params.output}/${name}/taxonomic-classification/taxonomy_results_combined/", mode: 'copy'
    label 'genomad' 

    input:
    tuple val(name), path(sourmash_file), path(genomad_file), path(phabox2_file), path(taxmyphage_file)
    // this is a bit     unsafe , what happens if one of the taxonomy tools is not run ? 
    output:
    tuple val(name), path("${name}_taxonomy_overview.tsv"), emit: taxonomy_combined_ch

    script:
    """
    #!/usr/bin/env python3
    import csv
    import sys
    import os

    sourmash_f = "${sourmash_file}"
    genomad_f = "${genomad_file}"
    phabox2_f = "${phabox2_file}"
    taxmyphage_f = "${taxmyphage_file}"
    output_f = "${name}_taxonomy_overview.tsv"

    data = {}

    # Define requested columns and their source mapping
    # Format: (Output_Column_Name, Source_File_Type, Source_Column_Name)
    requested_cols = [
        ("Sourmash_Similarity", "sourmash", "Similarity"),
        ("Sourmash_Predicted_accession_number", "sourmash", "Predicted_accession_number"),
        ("Sourmash_Taxonomy", "sourmash", "Taxonomy"),
        ("Genomad_agreement", "genomad", "agreement"),
        ("Genomad_taxid", "genomad", "taxid"),
        ("Genomad_lineage", "genomad", "lineage"),
        ("Phabox2_Lineage", "phabox2", "Lineage"),
        ("Phabox2_Genus", "phabox2", "Genus"),
        ("Phabox2_PhaGCNScore", "phabox2", "PhaGCNScore"),
        ("Taxmyphage_Taxonomy", "taxmyphage", "Full_taxonomy"),
        ("Taxmyphage_agreement", "taxmyphage", "Message"),
        ("Taxmyphage_Realm", "taxmyphage", "Realm"),
        ("Taxmyphage_Kingdom", "taxmyphage", "Kingdom"),
        ("Taxmyphage_Phylum", "taxmyphage", "Phylum"),
        ("Taxmyphage_Class", "taxmyphage", "Class"),
        ("Taxmyphage_Order", "taxmyphage", "Order"),
        ("Taxmyphage_Family", "taxmyphage", "Family"),
        ("Taxmyphage_Subfamily", "taxmyphage", "Subfamily"),
        ("Taxmyphage_Genus", "taxmyphage", "Genus"),
        ("Taxmyphage_Species", "taxmyphage", "Species")
    ]
    
    # Initialize data structure
    all_contigs = set()

    # Read Sourmash
    if os.path.exists(sourmash_f):
        with open(sourmash_f, 'r') as f:
            reader = csv.DictReader(f, delimiter='\\t')
            for row in reader:
                # Skip comments or empty rows if any
                if not row: continue
                
                # Sourmash first column key is usually 'Contig'
                # Check for 'Contig' key or fallback to first column if DictReader name is different
                contig = row.get('Contig')
                if not contig:
                    # Fallback strategies if header is slightly different or missing
                    # But based on previous steps, it is 'Contig'
                    current_keys = list(row.keys())
                    if current_keys:
                        contig = row[current_keys[0]]
                
                if not contig or contig.startswith('#'): continue
                
                all_contigs.add(contig)
                if contig not in data: data[contig] = {}
                
                # Store Sourmash data
                for out_col, src_type, src_col in requested_cols:
                    if src_type == "sourmash":
                        data[contig][out_col] = row.get(src_col, "NA")

    # Read Genomad
    if os.path.exists(genomad_f):
        with open(genomad_f, 'r') as f:
            # Genomad headers usually start with seq_name
            reader = csv.DictReader(f, delimiter='\\t')
            for row in reader:
                if not row: continue
                # Genomad key is 'seq_name'
                contig = row.get('seq_name')
                if not contig:
                     # Fallback
                    current_keys = list(row.keys())
                    if current_keys:
                        contig = row[current_keys[0]]

                if not contig or contig.startswith('#'): continue
                
                all_contigs.add(contig)
                if contig not in data: data[contig] = {}
                
                # Store Genomad data
                for out_col, src_type, src_col in requested_cols:
                    if src_type == "genomad":
                        data[contig][out_col] = row.get(src_col, "NA")

    # Read Phabox2
    if os.path.exists(phabox2_f):
        with open(phabox2_f, 'r') as f:
            reader = csv.DictReader(f, delimiter='\\t')
            for row in reader:
                if not row: continue
                # Phabox2 key is 'Accession'
                contig = row.get('Accession')
                if not contig:
                     # Fallback
                    current_keys = list(row.keys())
                    if current_keys:
                        contig = row[current_keys[0]]

                if not contig or contig.startswith('#'): continue
                
                all_contigs.add(contig)
                if contig not in data: data[contig] = {}
                
                # Store Phabox2 data
                for out_col, src_type, src_col in requested_cols:
                    if src_type == "phabox2":
                        data[contig][out_col] = row.get(src_col, "NA")

    # Write Output
    output_headers = ["Contig"] + [col[0] for col in requested_cols]

    with open(output_f, 'w', newline='') as f:
        writer = csv.writer(f, delimiter='\\t')
        writer.writerow(output_headers)
        
        for contig in sorted(list(all_contigs)):
            row = [contig]
            for col_name in output_headers[1:]:
                row.append(data[contig].get(col_name, 'NA'))
            writer.writerow(row)
    """

    stub:
    """
    touch "${name}_taxonomy_overview.tsv"
    """
}
