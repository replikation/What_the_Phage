process phage_references_blastDB {
        if (params.cloudProcess) {
           publishDir "${params.cloudDatabase}/", mode: 'copy', pattern: "blast_phage_DB"
        }
        else {
           storeDir "nextflow-autodownload-databases/"
        }
      label 'metaphinder'
    input:
      file(references)
    output:
      file("blast_phage_DB/")
    script:
      """
      makeblastdb -in ${references} -dbtype nucl -parse_seqids -out blast_phage_DB/phage_db -title phage_db
      """
}