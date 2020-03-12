process filter_sourmash {
      label 'ubuntu'
    input:
      tuple val(name), file(results)
    output:
      tuple val(name), file("sourmash_*.txt")
    shell:
      """
      cat *.list  > sourmash_\${PWD##*/}.txt
      """
}