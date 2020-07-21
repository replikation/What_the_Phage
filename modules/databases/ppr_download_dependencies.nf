process ppr_download_dependencies {
    if (params.cloudProcess) { publishDir "${params.databases}/pprmeta/", mode: 'copy', pattern: "PPR-Meta" }
    else { storeDir "${params.databases}/pprmeta/" }
    label 'noDocker'    
    output:
        path("PPR-Meta", type: 'dir')
    script:
        """
        git clone https://github.com/Stormrider935/PPR-Meta.git
        """
}