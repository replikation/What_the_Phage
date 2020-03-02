process deepvirfinder {
      label 'deepvirfinder'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_${random}.list")
    script:
      """
      
      dvf.py -c ${params.cpus} -i ${fasta} -o ${name}
      cp ${name}/*.txt ${name}_${random}.list
      """
}