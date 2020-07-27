process sourmash_download_DB {
    if (params.cloudProcess) { publishDir "${params.databases}/sourmash/", mode: 'copy', pattern: "phages.sbt.zip" }
    else { storeDir "${params.databases}/sourmash/" }
    label 'sourmash' 
    input:
        file(references)
    output:
        file("phages.sbt.zip")
    script:
        """
        sourmash compute --scaled 100 -k 21 --singleton --seed 42 -p 8 -o phages.sig ${references}
        sourmash index phages.sbt.zip phages.sig
        """
}
