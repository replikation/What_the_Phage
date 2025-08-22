process pvog_DB {
    label 'noDocker'
    errorStrategy 'retry'
    maxRetries 1    
    storeDir "${params.databases}/pvog"
    output:
        path("pvogs", type: 'dir')
    script:
        if (task.attempt.toString() == '1')
        """
        wget --no-check-certificate -nH ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/viral-pipeline/hmmer_databases/pvogs.tar.gz && tar -zxvf pvogs.tar.gz
        rm pvogs.tar.gz
        """

        else if (task.attempt.toString() == '2')
        """
        wget --no-check-certificate https://osf.io/n6ph5/download -O pvog.tar.gz
        tar -xvzf pvog.tar.gz
        cp -r pvog/pvogs/ .
        rm -r pvog
        rm pvog.tar.gz
        """
    
    stub:
        """
        mkdir -p pvogs
        """
}

process vogtable_DB {
    label 'noDocker' 
    //errorStrategy 'retry'
    //maxRetries 1   
    storeDir "${params.databases}/vog_table" 
    output:
        path("VOGTable.txt")
    script:
    // if (task.attempt.toString() == '1')
    //     """
    //     wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGTable.txt   
    //     """
    
    // else if (task.attempt.toString() == '2')
        """
        ## wget --no-check-certificate https://osf.io/nr6yb/download -O VOGTable.txt

        wget --no-check-certificate https://osf.io/9n75g/download -O vog_table.tar.gz
        tar -xvzf vog_table.tar.gz 
        mv vog_table/*.txt .
        rm vog_table.tar.gz
        """
    
    stub:
        """
        touch VOGTable.txt
        """
}

/*
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGTable.txt
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/GenomeTable.txt
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGProteinTable.txt
*/