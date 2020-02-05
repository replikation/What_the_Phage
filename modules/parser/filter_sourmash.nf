process filter_sourmash {
      label 'ubuntu'
    input:
      tuple val(name), file(results)
    output:
      tuple val(name), file("sourmash_*.txt")
    shell:
      """
      rnd=${Math.random()}
      cat *.list  > sourmash_\${rnd//0.}.txt
      """
}