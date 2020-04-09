process virfinder {
      label 'virfinder'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """
      virfinder_execute.R ${fasta} 
      cp results.txt ${name}_\${PWD##*/}.list
      """
}