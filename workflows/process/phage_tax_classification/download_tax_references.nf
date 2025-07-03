process download_references_standard {
    label 'noDocker'
    errorStrategy 'retry'
    maxRetries 1   
    storeDir "${params.databases}/references/"
    output:
        path("phage_references.fa")
    script:
        if (task.attempt.toString() == '1')
        """
        git clone -b WtP-v0.9 https://github.com/mult1fractal/WtP_phage_reference_db-WtP_v0.9.0.git
        cat WtP_phage_reference_db-WtP_v0.9.0/fasta-files/*.fa > phage_references.fa
        """

        else if (task.attempt.toString() == '2')
        """
        wget --no-check-certificate https://osf.io/6ukfx/download -O references.tar.gz
        tar -xvzf references.tar.gz
        cp references/*.fa .
        rm -r references/
        references.tar.gz
        """
    stub:
        """
        touch phage_references.fa
        """        
}

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
        touch phage_references.fasta
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
        touch phage_references.fasta
        """        
}

// is 32GB in size
// if permission errors -- chmod fasta files part001-3 tar and upload again