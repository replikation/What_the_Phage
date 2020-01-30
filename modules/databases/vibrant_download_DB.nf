process vibrant_download_DB {
        if (params.cloudProcess) {
           publishDir "${params.cloudDatabase}/Vibrant/", mode: 'copy', pattern: "database.tar.gz"
        }
        else {
           storeDir "nextflow-autodownload-databases/Vibrant"
        }
       label 'vibrant_download_DB'    
      output:
        file("database.tar.gz")
      script:
        """
        mkdir database
        mv /opt/conda/share/vibrant-1.0.1/* database/
        tar -czf database.tar.gz database/
        """
    }
