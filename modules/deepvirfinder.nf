process deepvirfinder {
      publishDir "${params.output}/${name}/deepvirfinder", mode: 'copy', pattern: "${name}.txt"
      label 'deepvirfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}.txt")
    script:
      """
      dvf.py -c ${params.cpus} -i ${fasta} -o ${name}
      cp ${name}/*.txt ${name}.txt
      """
}