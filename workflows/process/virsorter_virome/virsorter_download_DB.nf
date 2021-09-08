process virsorter_download_DB {
    errorStrategy 'retry'
    maxRetries 1
    label 'noDocker'    
    if (params.cloudProcess) { publishDir "${params.databases}/virsorter/", mode: 'copy', pattern: "virsorter-data" }
    else { storeDir "${params.databases}/virsorter/" }
    output:
        path("virsorter-data", type: 'dir')
    script:
        if (task.attempt.toString() == '1')
        """
        wget https://zenodo.org/record/1168727/files/virsorter-data-v2.tar.gz 
        tar -xvzf virsorter-data-v2.tar.gz
        rm virsorter-data-v2.tar.gz
        """
        if (task.attempt.toString() == '2')
        """
        wget https://osf.io/qwzu3/download -O virsorter.tar.gz
        tar -xvzf virsorter.tar.gz
        mv virsorter/virsorter-data/ .
        rm -r virsorter/
        rm virsorter.tar.gz
        """
    stub:
        """
        mkdir -p virsorter-data
        """
}


 // roughly 4 GB size