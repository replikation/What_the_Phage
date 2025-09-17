
// sourmash compute is deprecated, instead use sketch dna 
// https://sourmash.readthedocs.io/en/latest/using-sourmash-a-guide.html

process sourmash_NCBI_tax_build {
    label 'sourmash' 
    // errorStrategy 'retry'
    storeDir "${params.databases}/sourmash_tax/NCBI_tax"
    input:
        path(references)
    output:
        path("phages.sbt.zip"), emit: phage_db_ch
    script:
        """
        sourmash sketch dna -p scaled=100,k=21,seed=42,abund ${references} --name-from-first --singleton 
        sourmash index phages.sbt.zip *.sig
        """
    stub:
        """
        touch phages.sbt.zip
        """
}

process sourmash_phage_scope_tax_build {
    label 'sourmash' 
    // errorStrategy 'retry'
    storeDir "${params.databases}/sourmash_tax/phage_scope_tax"
    input:
        path(references)
    output:
        path("phages.sbt.zip"), emit: phage_db_ch
    script:
        """
        sourmash sketch dna -p scaled=100,k=21,seed=42,abund ${references} --name-from-first --singleton 
        sourmash index phages.sbt.zip *.sig
        """
    stub:
        """
        touch phages.sbt.zip
        """
}