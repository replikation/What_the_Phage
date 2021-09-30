process sourmash_download_DB {
    label 'sourmash' 
    errorStrategy 'retry'
    maxRetries 1
    if (params.cloudProcess) { publishDir "${params.databases}/sourmash/", mode: 'copy', pattern: "phages.sbt.zip" }
    else { storeDir "${params.databases}/sourmash/" }
    input:
        path(references)
    output:
        path("phages.sbt.zip")
    script:
        if (task.attempt.toString() == '1')
        """
        sourmash compute --scaled 100 -k 21 --singleton --seed 42 -p 8 -o phages.sig ${references}
        sourmash index phages.sbt.zip phages.sig
        """

        else if (task.attempt.toString() == '2')
        """
        wget https://osf.io/wm3gt/download -O sourmash.tar.gz
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
