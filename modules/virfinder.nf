process virfinder {
      publishDir "${params.output}/${name}/virfinder", mode: 'copy', pattern: "${name}.txt"
      label 'virfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}.txt")
    script:
      """
      virfinderGO.R ${fasta} | grep -v "\\[1\\]" > ${name}.txt
      """
}