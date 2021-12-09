process vog_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/vog", mode: 'copy', pattern: "vogdb" }
    else { storeDir "${params.databases}/vog" }  
    output:
        path("vogdb", type: 'dir')
    script:
        """
        wget --no-check-certificate -nH ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/viral-pipeline/hmmer_databases/vogdb.tar.gz && tar -zxvf vogdb.tar.gz
        rm vogdb.tar.gz
        """
}
