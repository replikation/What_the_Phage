process filter_vibrant {
      label 'ubuntu'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("vibrant_${random}.txt")
    script:
      """
      tail -q  -n+2 *.tsv | awk '{if(\$2=="virus"){print \$1}}' > vibrant_${random}.txt
      
      """
}