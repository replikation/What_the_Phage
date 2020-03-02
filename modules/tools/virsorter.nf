process virsorter {
      label 'virsorter'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta) 
      file(database) 
    output:
      tuple val(name), file("virsorter_${random}.list"), file("virsorter")
      // output collection stream
      tuple val(name), file("virsorter_results_${random}.tar")
    script:
      """
      rnd=${Math.random()}
      wrapper_phage_contigs_sorter_iPlant.pl -f ${fasta} -db 1 --wdir virsorter --ncpu 8 --data-dir ${database}
      cat virsorter/Predicted_viral_sequences/VIRSorter_cat-[1,2].fasta | grep ">" | sed -e s/\\>VIRSorter_//g | sed -e s/-cat_1//g |  sed -e s/-cat_2//g | sed -e s/-circular//g > virsorter_${random}.list

      tar cf virsorter_results_${random}.tar virsorter
      """
}