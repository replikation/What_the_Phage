process virfinder {
      label 'virfinder'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """
      rnd=${Math.random()}
      virfinder_execute.R ${fasta} 
      cp results.txt ${name}_\${rnd//0.}.list
      """
}