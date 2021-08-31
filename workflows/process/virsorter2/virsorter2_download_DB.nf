process virsorter2_download_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/virsorter2-db", mode: 'copy' }
    else { storeDir "${params.databases}/virsorter2-db" }  
    output:
        path('db', type: 'dir')
    script:
        """
        wget https://osf.io/v46sc/download -O db.tgz
        tar -zxvf db.tgz
        chmod -R a+rX db
        rm db.tgz
        """
    stub:
        """
        mkdir -p db
        """
}

