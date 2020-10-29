process fastqTofasta {
    label 'emboss'
    input:
        tuple val(name), file(fastq)
    output:
        tuple val(name), file("${name}_*.fa")
    script:
        """
        seqret -sequence ${fastq} -outseq ${name}_\${PWD##*/}.fa
      
        # trimm fasta header to first space
          sed '/^>/ s/ .*//' -i ${name}_\${PWD##*/}.fa
        # replace , with _
          sed 's#,#_#g' -i ${name}_\${PWD##*/}.fa
        # replace . with _
          sed 's#\\.#_#g' -i ${name}_\${PWD##*/}.fa
        # replace | with _
          sed 's#|#_#g' -i ${name}_\${PWD##*/}.fa
        # remove empty lines
          sed '/^\$/d' -i ${name}_\${PWD##*/}.fa
        """
}