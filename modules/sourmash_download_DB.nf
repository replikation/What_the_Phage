process sourmash_download_DB {
        if (params.cloudProcess) {
           publishDir "${params.cloudDatabase}/sourmash/", mode: 'copy', pattern: "phages.sbt.json"
        }
        else {
           storeDir "nextflow-autodownload-databases/sourmash/"
        }
       label 'sourmash' 
      input:
        file(references)
      output:
        tuple file("phages.sbt.json"), file(".sbt.phages")
      script:
        """
         sourmash compute --scaled 100 -k 21 --singleton --seed 42 -p 8 -o phages.sig ${references}
         sourmash index phages phages.sig
        """
    }
