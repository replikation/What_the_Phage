process deepvirfinder {
      publishDir "${params.output}/${name}/deepvirfinder", mode: 'copy', pattern: "${name}_*.list"
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