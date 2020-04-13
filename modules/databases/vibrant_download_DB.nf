process vibrant_download_DB {
        if (params.cloudProcess) {
           publishDir "${params.databases}/Vibrant/", mode: 'copy', pattern: "database.tar.gz"
        }
        else {
           storeDir "${params.databases}/Vibrant"
        }
       label 'vibrant'    
      output:
        file("database.tar.gz")
      script:
        """
        mkdir database
        cd database
        cp -r /opt/conda/share/vibrant-1.0.1/databases/profile_names .
        /opt/conda/share/vibrant-1.0.1/databases/VIBRANT_setup.py
        cp /opt/conda/share/vibrant-1.0.1/files/VIBRANT* .
        ls
        cd ..
        tar -czf database.tar.gz database/
        """
    }
