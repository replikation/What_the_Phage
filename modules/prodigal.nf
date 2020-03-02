process prodigal {
      publishDir "${params.output}/${name}/prodigal_out", mode: 'copy'
      label 'prodigal'

    input:
    tuple val(name), file(positive_contigs) 
    
    output:
    tuple val(name), file("${name}_prodigal.faa")
    
    script:
    """
    prodigal -p "meta" -a ${name}_prodigal.faa -i ${positive_contigs}
    """
}