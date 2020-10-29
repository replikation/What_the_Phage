process prodigal {
        publishDir "${params.output}/${name}/raw_data/prodigal_out", mode: 'copy'
        label 'prodigal'
    input:
        tuple val(name), path(positive_contigs) 
    output:
        tuple val(name), path("${name}_prodigal.faa")
    script:
        """
        prodigal -p "meta" -a ${name}_prodigal.faa -i ${positive_contigs}
        """
}
