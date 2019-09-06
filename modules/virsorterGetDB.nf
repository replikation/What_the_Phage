process virsorterGetDB {
        storeDir 'nextflow-autodownload-databases/virsorter'
        label 'ubuntu'    
      output:
        file("virsorter-data")
      script:
        """
        wget https://zenodo.org/record/1168727/files/virsorter-data-v2.tar.gz 
        tar -xvzf virsorter-data-v2.tar.gz
        rm virsorter-data-v2.tar.gz
        """
    }


 // roughly 4 GB size