process filter_PPRmeta {
      label 'ubuntu'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("PPRmeta_${random}.txt")
    script:
      """
      cat *.csv | grep -v "Header,Length,phage_score," | grep ',phage\$' | cut -d ',' -f1 > PPRmeta_${random}.txt
      """
}