process ppr_download_dependencies {
        storeDir 'nextflow-autodownload-databases/pprmeta'
        label 'noDocker'    
      output:
        file("PPR-Meta")
      script:
        """
        git clone https://github.com/Stormrider935/PPR-Meta.git
        """
    }