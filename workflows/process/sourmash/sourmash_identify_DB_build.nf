process sourmash_identify_DB_build {
    label 'sourmash' 
    errorStrategy 'retry'
    maxRetries 1
    storeDir "${params.databases}/sourmash_identify/"
    input:
        path(references)
    output:
        path("phages.sbt.zip")
    script:
        if (task.attempt.toString() == '1')
        """
        sourmash sketch dna -p scaled=100,k=21,seed=42,abund ${references} --name-from-first --singleton
        sourmash index phages.sbt.zip phages.sig
        """

        else if (task.attempt.toString() == '2')
        """
        wget --no-check-certificate https://osf.io/wm3gt/download -O sourmash.tar.gz
        tar -xvzf sourmash.tar.gz
        mv sourmash/* .
        rm -r sourmash/
        rm sourmash.tar.gz
        """

    stub:
        """
        touch phages.sbt.zip
        """
}
