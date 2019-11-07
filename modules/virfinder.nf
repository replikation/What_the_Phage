process virfinder {
      publishDir "${params.output}/${name}/virfinder", mode: 'copy', pattern: "${name}_*.list"
      label 'virfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """
      rnd=${Math.random()}
      virfinderGO.R ${fasta} | grep -v "\\[1\\]" > ${name}_\${rnd//0.}.list
      """
}