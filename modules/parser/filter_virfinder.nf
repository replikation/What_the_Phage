process filter_virfinder {
      label 'ubuntu'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virfinder_${random}.txt")
    script:
      """
      tail -q -n+2 *.list | awk '\$4>=0.9' | awk '{ print \$2 }' > virfinder_${random}.txt
      """
}