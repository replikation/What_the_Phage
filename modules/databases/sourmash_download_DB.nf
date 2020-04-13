process sourmash_download_DB {
        if (params.cloudProcess) {
           publishDir "${params.databases}/sourmash/", mode: 'copy', pattern: "phages.sbt.json.tar.gz"
        }
        else {
           storeDir "${params.databases}/sourmash/"
        }
       label 'sourmash' 
      input:
        file(references)
      output:
        file("phages.sbt.json.tar.gz")
      script:
        """
         sourmash compute --scaled 100 -k 21 --singleton --seed 42 -p 8 -o phages.sig ${references}
         sourmash index phages phages.sig
         tar czf phages.sbt.json.tar.gz phages.sbt.json .sbt.phages
        """
    }
