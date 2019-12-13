process virsorter {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "virsorter"
      label 'virsorter'
    input:
      tuple val(name), file(fasta) 
      file(database) 
    output:
      tuple val(name), file("virsorter_*.list"), file("virsorter")
    script:
      """
      rnd=${Math.random()}
      wrapper_phage_contigs_sorter_iPlant.pl -f ${fasta} -db 1 --wdir virsorter --ncpu 8 --data-dir ${database}
      cat virsorter/Predicted_viral_sequences/VIRSorter_cat-[1,2].fasta | grep ">" | sed -e s/\\>VIRSorter_//g | sed -e s/-cat_1//g |  sed -e s/-cat_2//g | sed -e s/-circular//g > virsorter_\${rnd//0.}.list
      """
}