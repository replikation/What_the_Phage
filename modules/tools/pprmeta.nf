process pprmeta {
      label 'pprmeta'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
      file(depts) 
    output:
      tuple val(name), file("${name}_*.csv")
    script:
      """
      rnd=${Math.random()}
      cp ${depts}/* .
      ./PPR_Meta ${fasta} ${name}_\${rnd//0.}.csv
      """
}

 // .fasta is not working here. has to be .fa
 // need to implement this so its fixed 
