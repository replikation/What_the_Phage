process fastqTofasta {
      label 'emboss'
    input:
      tuple val(name), file(fastq)
    output:
      tuple val(name), file("${name}.fa")
    script:
      """
      seqret -sequence ${fastq} -outseq ${name}.fa
      
      # trimm fasta header to first space
        sed '/^>/ s/ .*//' -i ${name}.fa
      # replace , with _
        sed 's#,#_#g' -i ${name}.fa
      # replace . with _
        sed 's#\\.#_#g' -i ${name}.fa
      """
}