process download_references {
    label 'noDocker'
    errorStrategy 'retry'
    maxRetries 1   
    if (params.cloudProcess) { publishDir "${params.databases}/references/", mode: 'copy', pattern: "phage_references.fa" }
    else { storeDir "${params.databases}/references/" }    
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
        mv references/*.fa .
        rm -r references.tar.gz
        """
    stub:
        """
        touch phage_references.fa
        """        
}