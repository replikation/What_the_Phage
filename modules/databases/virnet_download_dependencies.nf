process virnet_download_dependencies {
      if (params.cloudProcess) {
         publishDir "${params.databases}/virnet/", mode: 'copy', pattern: "virnet"
      }
      else {
         storeDir "${params.databases}/virnet/"
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