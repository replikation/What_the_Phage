process filter_virsorter {
      label 'ubuntu'
    input:
      tuple val(name), file(results), file(dir)
    output:
      tuple val(name), file("virsorter_*.txt")
    shell:
      """
      cat *.list  > virsorter_\${PWD##*/}.txt
      """
}