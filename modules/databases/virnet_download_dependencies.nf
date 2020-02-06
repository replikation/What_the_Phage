process virnet_download_dependencies {
      if (params.cloudProcess) {
         publishDir "${params.cloudDatabase}/virnet/", mode: 'copy', pattern: "virnet"
      }
      else {
         storeDir "nextflow-autodownload-databases/virnet/"
      }
      label 'noDocker'    
      output:
        file("virnet")
      script:
        """
        git clone https://github.com/Stormrider935/virnet.git
        chmod 777 virnet/*.py
        """
    }