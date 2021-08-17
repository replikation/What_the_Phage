process virsorter_download_DB {
    if (params.cloudProcess) { publishDir "${params.databases}/virsorter/", mode: 'copy', pattern: "virsorter-data" }
    else { storeDir "${params.databases}/virsorter/" }
    label 'noDocker'    
    output:
        path("virsorter-data", type: 'dir')
    script:
        """
        wget https://zenodo.org/record/1168727/files/virsorter-data-v2.tar.gz 
        tar -xvzf virsorter-data-v2.tar.gz
        rm virsorter-data-v2.tar.gz
        """
    stub:
        """
        mkdir virsorter-data
        """
}


 // roughly 4 GB size