process download_references_NCBI {
    label 'noDocker'
    //errorStrategy 'retry'
    storeDir "${params.databases}/NCBI_tax" 
    output:
        path("*.fa"), emit: phage_ref_ch
        path("refseq_phage_meta_data.tsv"), emit:  ncbi_tax_metadata_ch
    script:
        """
        wget --no-check-certificate https://osf.io/4t7zh/download -O NCBI-Refseq_phages.tar.gz
        tar -xzvf NCBI-Refseq_phages.tar.gz
        mv NCBI-Refseq_phages/*.fa .
        mv NCBI-Refseq_phages/refseq_phage_meta_data.tsv .
        rm -r NCBI-Refseq_phages
        """
    stub:
        """
        touch refseq_phage_references.fa
        touch refseq_phage_meta_data.tsv
        """        
}
//note - go to osf webpage project - click on tar.gz file to get the proper link , otherwise you will get a html

process download_references_phage_scope {
    label 'noDocker'
    //errorStrategy 'retry'
    storeDir "${params.databases}/phage_scope_tax" 
    output:
        path("*.fasta"), emit: phage_ref_ch
        path("*_metadata*.tsv"), emit:  phagescope_tax_metadata_ch
    script:
        """
        wget --no-check-certificate https://osf.io/ew8jg/download -O phagescope-phage_sequences_part_001.tar.gz
        wget --no-check-certificate https://osf.io/m8sau/download -O phagescope-phage_sequences_part_002.tar.gz
        wget --no-check-certificate https://osf.io/dyszk/download -O phagescope-phage_sequences_part_003.tar.gz

        tar -xzvf phagescope-phage_sequences_part_001.tar.gz
        tar -xzvf phagescope-phage_sequences_part_002.tar.gz
        tar -xzvf phagescope-phage_sequences_part_003.tar.gz

        cat phage_scope_sourmash_*/*.fasta > all_phagescope-phage_sequences.fasta
        # gzip all_phagescope-phage_sequences.fasta  very slow
        mv  phage_scope_sourmash_1/all_phagescope_metadata_*_V1.tsv .
        
        rm -r phage_scope_sourmash_*
        """
    stub:
        """
        touch all_phagescope-phage_sequences.fasta
        touch all_phagescope_metadata_V1.tsv
        """        
}

// is 32GB in size
// if permission errors -- chmod fasta files part001-3 tar and upload again