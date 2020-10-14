process virsorter2 {
      label 'virsorter2'
      errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta)  
    output:
      tuple val(name), path("virsorter2_*.out/final-viral-score.tsv")
      tuple val(name), path("virsorter2_*.out")
    script:
      """
        virsorter run -w virsorter2_\${PWD##*/}.out -i ${fasta}  -j ${task.cpus}
      """
}


//        tar cf virsorter2_results_\${PWD##*/}.out.tar virsorter2_\${PWD##*/}.out

//