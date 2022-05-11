process phage_references_blastDB {
    if (params.cloudProcess) { publishDir "${params.databases}/blast_DB_phage", mode: 'copy', pattern: "blast_database.tar.gz" }
    else { storeDir "${params.databases}/blast_DB_phage" }
    label 'metaphinder'
    errorStrategy = "retry"
    maxRetries = 1
    input:
        path(references)
    output:
        path("blast_database.tar.gz")
    script:
        if (task.attempt.toString() == '1')
        """
        makeblastdb -in ${references} -dbtype nucl -parse_seqids -out phage_db -title phage_db
        mkdir phage_blast_DB && mv phage_db.* phage_blast_DB
        tar czf blast_database.tar.gz phage_blast_DB/
        """

        else if (task.attempt.toString() == '2')
        """
        wget --no-check-certificate https://osf.io/7gcky/download -O blast_database.tar.gz
        """

    stub:
        """
        mkdir phage_blast_DB
        tar czf blast_database.tar.gz phage_blast_DB/
        """        
}

//phage_blast_DB/phage_db.*