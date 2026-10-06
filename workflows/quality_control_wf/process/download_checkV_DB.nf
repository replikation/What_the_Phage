
process download_checkV_DB {
    label 'noDocker'    
    storeDir "${params.databases}/checkV"
    output:
        path("checkv-db-v*", type: 'dir')
    script:
        """
        wget --no-check-certificate https://portal.nersc.gov/CheckV/checkv-db-v0.6.tar.gz
        tar -zxvf checkv-db-v0.6.tar.gz
        rm checkv-db-v0.6.tar.gz
        """
    stub:
        """
        mkdir -p checkv-db-v0.6
        """
}