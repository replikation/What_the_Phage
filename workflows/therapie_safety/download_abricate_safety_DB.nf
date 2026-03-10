process download_abricate_safety_DB {
    label 'ubuntu'
    //errorStrategy 'ignore'
    storeDir "${params.databases}/abricate_safety_db"
    output:
        path("abricate_safety_db_*")
    script:
        """
        wget -O abricate_safety_db_1.0.1.tar.gz https://zenodo.org/records/14886553/files/genomad_db_v1.9.tar.gz?download=1
    
        """    
    stub:
        """
        mkdir -p abricate_safety_db
        """
}   