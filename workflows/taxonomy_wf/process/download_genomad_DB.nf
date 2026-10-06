process download_genomad_DB {
    label 'ubuntu'
    //errorStrategy 'ignore'
    storeDir "${params.databases}/genomad_db"
    output:
        path("genomad_db_*")
    script:
        """
        wget -O genomad_db_1.9.tar.gz https://zenodo.org/records/14886553/files/genomad_db_v1.9.tar.gz?download=1
    
        """    
    stub:
        """
        touch genomad_db_stub.tar.gz
        """
}