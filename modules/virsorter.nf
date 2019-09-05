process virsorter {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "virsorter"
      label 'virsorter'
    input:
      set val(name), file(fasta) 
      file(database) 
    output:
      set val(name), file("virsorter")
    script:
      """
      wrapper_phage_contigs_sorter_iPlant.pl -f ${fasta} -db 1 --wdir virsorter --ncpu 8 --data-dir ${database}
      """
}