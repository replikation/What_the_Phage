process deepvirfinder {
      label 'deepvirfinder'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """  
      dvf.py -c ${params.cpus} -i ${fasta} -o ${name}
      cp ${name}/*.txt ${name}_\${PWD##*/}.list
      """
}