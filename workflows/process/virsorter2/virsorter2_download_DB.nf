process virsorter2_download_DB {
    label 'noDocker'    
    storeDir "${params.databases}/virsorter2-db"
    output:
        path('db', type: 'dir')
    script:
        """
        wget --no-check-certificate https://osf.io/v46sc/download -O db.tgz
        tar -zxvf db.tgz
        chmod -R a+rX db
        rm db.tgz
        """
    stub:
        """
        mkdir -p db
        """
}

