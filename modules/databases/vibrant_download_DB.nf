process vibrant_download_DB {
        // if (params.cloudProcess) {
        //    publishDir "${params.cloudDatabase}/virsorter/", mode: 'copy', pattern: "virsorter-data"
        // }
        // else {
           storeDir "nextflow-autodownload-databases/Vibrant"
        // }
       label 'vibrant_download_DB'    
      output:
        file("database.tar.gz")
      script:
        """
        mkdir database
        mv /opt/conda/share/vibrant-1.0.1/databases/* database/
        tar -czf database.tar.gz database/
        """
    }
        // git clone https://github.com/AnantharamanLab/VIBRANT.git
        // chmod 777 VIBRANT/databases/*
        // cd VIBRANT/databases && ./VIBRANT_setup.py && ./VIBRANT_test_setup.py
        // tar -czf VIBRANT.tar.gz VIBRANT/