process phage_references_blastDB {
    if (params.cloudProcess) { publishDir "${params.databases}/", mode: 'copy', pattern: "phage_blast_DB" }
    else { storeDir "${params.databases}/blast_DB_phage" }
    label 'metaphinder'
    errorStrategy = "retry"
    maxRetries = 2
    input:
        path(references)
    output:
        path("phage_blast_DB/", type: 'dir')
    script:
        """
        makeblastdb -in ${references} -dbtype nucl -parse_seqids -out phage_db -title phage_db
        mkdir phage_blast_DB && mv phage_db.* phage_blast_DB
        """
}

//phage_blast_DB/phage_db.*