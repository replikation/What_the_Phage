process deepvirfinder {
      publishDir "${params.output}/${name}/deepvirfinder", mode: 'copy', pattern: "${name}.txt"
      label 'deepvirfinder'
    input:
      set val(name), file(fasta) 
    output:
      set val(name), file("${name}.txt")
    script:
      """
      dvf.py -c ${params.cpus} -i ${fasta} -o ${name}
      cp ${name}/*.txt ${name}.txt
      """
}