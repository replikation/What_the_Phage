process download_references_NCBI_identify {
    label 'noDocker'
    errorStrategy 'retry'
    maxRetries 1   
    storeDir "${params.databases}/references/" 
    output:
        path("phage_references.fa")
    script:
        if (task.attempt.toString() == '1')
        """
        wget --no-check-certificate https://osf.io/4t7zh/download -O NCBI-Refseq_phages.tar.gz
        tar -xzvf NCBI-Refseq_phages.tar.gz
        mv NCBI-Refseq_phages/*.fa .
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


