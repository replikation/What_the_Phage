process download_virsorter2_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/virsorter2-db", mode: 'copy' }
    else { storeDir "${params.databases}/virsorter2-db" }  
    output:
        path("virsorter2-db", type: 'dir')
    script:
        """
        wget https://osf.io/v46sc/download -O db.tgz
        mkdir virsorter2-db
        tar -zxvf db.tgz virsorter2-db --strip-components=1 -C virsorter2-db
        chmod a+rX virsorter2-db
        rm -f db.tgz
        """
}
