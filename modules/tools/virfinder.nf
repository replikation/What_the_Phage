process virfinder {
      label 'virfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """
      rnd=${Math.random()}
      virfinderGO.R ${fasta} > ${name}_\${rnd//0.}.list
      """
}