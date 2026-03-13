process virsorter2_prophage {
    publishDir "${params.output}/${name}/prophage/virsorter2", mode: 'copy'
    publishDir "${params.output}/${name}/raw_data/", mode: 'copy', pattern: "${name}_virsorter2_prophage_output.tar.gz" 
    label 'virsorter2'
    errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta)  
      path(database)
    output:
        tuple val(name), path("virsorter2.out/*_final-viral-score_virsorter2.tsv"), emit: virsorter2_prophage_ch, optional: true
        tuple val(name), path("virsorter2.out")
    script:
        """
        virsorter run -d ${database} \
        -w virsorter2.out \
        -i ${fasta} \
        -j ${task.cpus} \

        mv virsorter2.out/final-viral-score.tsv virsorter2.out/${name}_final-viral-score_virsorter2.tsv

        # zip for export
        tar -czf ${name}_virsorter2_prophage_output.tar.gz virsorter2.out

        """
    stub:
        """
        mkdir virsorter2_\${PWD##*/}.out
        echo "seqname    dsDNAphage    NCLDV    RNA    ssDNA    lavidaviridae" > virsorter2.out/final-viral-score.tsv
        echo "pos_phage_0    1    0.133    0.005    0.14    0.04" >> virsorter2.out/final-viral-score.tsv   
        """
}



//        tar cf virsorter2_results_\${PWD##*/}.out.tar virsorter2_\${PWD##*/}.out

//
