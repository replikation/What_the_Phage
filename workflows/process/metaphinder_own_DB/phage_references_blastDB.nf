process phage_references_blastDB {
    if (params.cloudProcess) { publishDir "${params.databases}/blast_DB_phage", mode: 'copy', pattern: "blast_database.tar.gz" }
    else { storeDir "${params.databases}/blast_DB_phage" }
    label 'metaphinder'
    errorStrategy = "retry"
    maxRetries = 2
    input:
        path(references)
    output:
        path("blast_database.tar.gz")
    script:
        """
        makeblastdb -in ${references} -dbtype nucl -parse_seqids -out phage_db -title phage_db
        mkdir phage_blast_DB && mv phage_db.* phage_blast_DB
        tar czf blast_database.tar.gz phage_blast_DB/
        """
    stub:
        """
        mkdir phage_blast_DB
        tar czf blast_database.tar.gz phage_blast_DB/
        """        
}

//phage_blast_DB/phage_db.*