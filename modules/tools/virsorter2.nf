process virsorter2 {
    label 'virsorter2'
    errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta)  
      path(database)
    output:
        tuple val(name), path("virsorter2_*.out/final-viral-score.tsv")
        tuple val(name), path("virsorter2_*.out")
    script:
        """
        virsorter run -d ${database} \
        -w virsorter2_\${PWD##*/}.out \
        -i ${fasta} \
        -j ${task.cpus}
        """
    stub:
        """
        mkdir virsorter2_\${PWD##*/}.out
        echo "seqname    dsDNAphage    NCLDV    RNA    ssDNA    lavidaviridae" > virsorter2_\${PWD##*/}.out/final-viral-score.tsv
        echo "pos_phage_0    1    0.133    0.005    0.14    0.04" >> virsorter2_\${PWD##*/}.out/final-viral-score.tsv   
        """
}



//        tar cf virsorter2_results_\${PWD##*/}.out.tar virsorter2_\${PWD##*/}.out

//
