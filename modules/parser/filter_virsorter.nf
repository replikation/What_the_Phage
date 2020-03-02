process filter_virsorter {
      label 'ubuntu'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(results), file(dir)
    output:
      tuple val(name), file("virsorter_${random}.txt")
    shell:
      """
      cat *.list  > virsorter_${random}.txt
      """
}