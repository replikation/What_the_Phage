process virfinder {
      publishDir "${params.output}/${name}/virfinder", mode: 'copy', pattern: "${name}.txt"
      label 'virfinder'
    input:
      set val(name), file(fasta) 
    output:
      set val(name), file("${name}.txt")
    script:
      """
      virfinderGO.R ${fasta} | grep -v "\\[1\\]" > ${name}.txt
      """
}