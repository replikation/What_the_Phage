process phage_references_blastDB {
    if (params.cloudProcess) { publishDir "${params.databases}/", mode: 'copy', pattern: "phage_db.*" }
    else { storeDir "${params.databases}/blast_phage_DB" }
    label 'metaphinder'
    input:
        path(references)
    output:
        path("phage_db.*")
    script:
        """
        makeblastdb -in ${references} -dbtype nucl -parse_seqids -out phage_db -title phage_db
        """
}