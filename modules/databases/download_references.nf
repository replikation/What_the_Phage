process download_references {
    if (params.cloudProcess) { publishDir "${params.databases}/references/", mode: 'copy', pattern: "phage_references.fa" }
    else { storeDir "${params.databases}/references/" }
    label 'noDocker'    
    output:
        path("phage_references.fa")
    script:
        """
        git clone -b WtP-v0.9 https://github.com/mult1fractal/WtP_phage_reference_db-WtP_v0.9.0.git
        cat WtP_phage_reference_db-WtP_v0.9.0/fasta-files/*.fa > phage_references.fa
        """
}