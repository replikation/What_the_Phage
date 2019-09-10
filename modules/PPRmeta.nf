process pprmeta {
      publishDir "${params.output}/${name}/PPR-Meta", mode: 'copy', pattern: "${name}.csv"
      label 'pprmeta'
    input:
      set val(name), file(fasta) 
      file(depts) 
    output:
      set val(name), file("${name}.csv")
    script:
      """
      cp ${depts}/* .
      ./PPR_Meta ${fasta} ${name}.csv
      """
}

 // .fasta is not working here. has to be .fa
 // need to implement this so its fixed 
