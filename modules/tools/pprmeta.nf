process pprmeta {
      label 'pprmeta'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta) 
      file(depts) 
    output:
      tuple val(name), file("${name}_${random}.csv")
    script:
      """
      cp ${depts}/* .
      ./PPR_Meta ${fasta} ${name}_${random}.csv
      """
}

 // .fasta is not working here. has to be .fa
 // need to implement this so its fixed 
