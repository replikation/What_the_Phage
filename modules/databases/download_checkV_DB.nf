
process download_checkV_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/checkV", mode: 'copy' }
    else { storeDir "${params.databases}/checkV" }  
    output:
        path("checkv-db-v*", type: 'dir')
    script:
        """
        wget https://portal.nersc.gov/CheckV/checkv-db-v0.6.tar.gz
        tar -zxvf checkv-db-v0.6.tar.gz
        rm checkv-db-v0.6.tar.gz
        """
    stub:
        """
        mkdir checkv-db-v0.6
        """
}