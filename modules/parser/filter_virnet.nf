process filter_virnet {
      label 'ubuntu'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virnet_${random}.txt")
    script:
      """
      tail -q  -n+2 *.csv | sed 's|,|\\t|g' | awk '{if(\$6==1){print \$2}}' | sort | uniq | tr -d '"' > virnet_${random}.txt
      """
}

