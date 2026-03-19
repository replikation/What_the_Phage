process download_iphop_DB {
    label 'iphop'
    //errorStrategy 'ignore'
    storeDir "${params.databases}"
    output:
        path("iphop_db")
    script:
        """
        iphop_db_ver="iPHoP_db_Jun25_rw"
        mkdir iphop_db
        iphop download --db_dir iphop_db --no_prompt --split -dbv \${iphop_db_ver}
        chmod -R 777 iphop_db
        rm -f iphop_db/*.tar.gz* ## remove to save space
        """    
    stub:
        """
        mkdir -p iphop_db
        """
}