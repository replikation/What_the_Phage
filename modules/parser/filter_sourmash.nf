process filter_sourmash {
      label 'ubuntu'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(results)
    output:
      tuple val(name), file("sourmash_${random}.txt")
    shell:
      """
      cat *.list  > sourmash_${random}.txt
      """
}