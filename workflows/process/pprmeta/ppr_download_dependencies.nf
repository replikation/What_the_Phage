process ppr_download_dependencies {
    errorStrategy 'retry'
    maxRetries 1
    label 'noDocker'
    if (params.cloudProcess) { publishDir "${params.databases}/pprmeta/", mode: 'copy', pattern: "PPR-Meta" }
    else { storeDir "${params.databases}/pprmeta/" }    
    output:
        path("PPR-Meta", type: 'dir')
    script:
        if (task.attempt.toString() == '1')
        """
        git clone https://github.com/Stormrider935/PPR-Meta.git
        """

        else if (task.attempt.toString() == '2')
        """
        wget --no-check-certificate https://osf.io/vchg9/download -O pprmeta.tar.gz
        tar -xvzf pprmeta.tar.gz
        mv pprmeta/PPR-Meta/ .
        rm -r pprmeta/
        rm pprmeta.tar.gz

        """

    stub:
        """
        mkdir -p PPR-Meta
        """        
}