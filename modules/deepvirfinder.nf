process deepvirfinder {
      label 'deepvirfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """
      rnd=${Math.random()}
      dvf.py -c ${params.cpus} -i ${fasta} -o ${name}
      cp ${name}/*.txt ${name}_\${rnd//0.}.list
      """
}