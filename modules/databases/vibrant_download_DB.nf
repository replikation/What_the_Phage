process vibrant_download_DB {
        // if (params.cloudProcess) {
        //    publishDir "${params.cloudDatabase}/virsorter/", mode: 'copy', pattern: "virsorter-data"
        // }
        // else {
           storeDir "nextflow-autodownload-databases/vibrant/"
        // }
       label 'vibrant'    
      output:
        file("vibrant-DB")
      script:
        """
        git clone https://github.com/AnantharamanLab/VIBRANT.git
        chmod -R 777 VIBRANT
        ./VIBRANT_setup.py
        
        """
    }
