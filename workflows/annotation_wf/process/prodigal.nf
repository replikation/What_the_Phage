process prodigal {
        label 'prodigal'
    input:
        tuple val(name), path(positive_contigs) 
    output:
        tuple val(name), path("${name}_prodigal.faa")
    script:
        """
        prodigal -p "meta" -a ${name}_prodigal.faa -i ${positive_contigs}
        """
    stub:
        """
        touch ${name}_prodigal.faa
        """
}
