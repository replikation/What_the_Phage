process ppr_download_dependencies {
      if (params.cloudProcess) {
         publishDir "${params.cloudDatabase}/pprmeta/", mode: 'copy', pattern: "PPR-Meta"
      }
      else {
         storeDir "nextflow-autodownload-databases/pprmeta/"
      }
      label 'noDocker'    
      output:
        file("PPR-Meta")
      script:
        """
        git clone https://github.com/Stormrider935/PPR-Meta.git
        """
    }