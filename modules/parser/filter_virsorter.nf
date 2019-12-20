process filter_virsorter {
      publishDir "${params.output}/${name}/virsorter", mode: 'copy', pattern: "virsorter_*.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results), file(dir)
    output:
      tuple val(name), file("virsorter_*.txt")
    shell:
      """
      rnd=${Math.random()}
      cat *.list  > virsorter_\${rnd//0.}.txt
      """
}