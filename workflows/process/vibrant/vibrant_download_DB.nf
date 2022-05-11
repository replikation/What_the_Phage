process vibrant_download_DB {
    errorStrategy 'retry'
    maxRetries 1
    label 'vibrant'
    if (params.cloudProcess) { publishDir "${params.databases}/Vibrant/", mode: 'copy', pattern: "database.tar.gz" }
    else { storeDir "${params.databases}/Vibrant" }    
    output:
        path("database.tar.gz")
    script:
        if (task.attempt.toString() == '1')
        """
        # profile names for VIBRANT_setup.py
        cp -r /opt/conda/share/vibrant-1.0.1/databases/profile_names .
        /opt/conda/share/vibrant-1.0.1/databases/VIBRANT_setup.py

        # pack together database
        mkdir database && mv *.{HMM,h3?} database
        cp /opt/conda/share/vibrant-1.0.1/files/VIBRANT*.{tsv,sav} database
        tar -czf database.tar.gz database/
        """

        else if (task.attempt.toString() == '2')
        """
        wget --no-check-certificate https://osf.io/j7435/download -O database.tar.gz
        """


    stub:
        """
        mkdir database
        tar -czf database.tar.gz database/
        """
}


/*
mkdir database
cd database
cp -r /opt/conda/share/vibrant-1.0.1/databases/profile_names .
/opt/conda/share/vibrant-1.0.1/databases/VIBRANT_setup.py
cp /opt/conda/share/vibrant-1.0.1/files/VIBRANT* .
cd ..
tar -czf database.tar.gz database/
*/