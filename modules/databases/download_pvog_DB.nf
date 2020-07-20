process pvog_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/", mode: 'copy'}
    else { storeDir "${params.databases}/pvog" }  
    output:
        path("pvogs", type: 'dir')
    script:
        """
        wget -nH ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/viral-pipeline/hmmer_databases/pvogs.tar.gz && tar -zxvf pvogs.tar.gz
        rm pvogs.tar.gz
        """
}

process vogtable_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/vog_table", mode: 'copy'}
    else { storeDir "${params.databases}/vog_table" }  
    output:
        path("VOGTable.txt")
    script:
        """
        wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGTable.txt
        """
}

/*
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGTable.txt
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/GenomeTable.txt
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGProteinTable.txt
*/