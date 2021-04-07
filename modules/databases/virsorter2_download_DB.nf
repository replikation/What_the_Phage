process download_virsorter2_DB {
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/virsorter2-db", mode: 'copy' }
    else { storeDir "${params.databases}/virsorter2-db" }  
    output:
        path('db', type: 'dir')
    script:
        """
        wget https://osf.io/v46sc/download -O db.tgz
        mkdir db
        tar -zxvf db.tgz --strip-components=1 -C db
        chmod -R a+rX db
        rm db.tgz
        """
}

