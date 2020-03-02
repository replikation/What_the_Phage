process virfinder {
      label 'virfinder'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_${random}.list")
    script:
      """
      rnd=${Math.random()}
      virfinder_execute.R ${fasta} 
      cp results.txt ${name}_${random}.list
      """
}