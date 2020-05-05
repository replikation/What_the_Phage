process seqkit {
        label 'seqkit'
    input:
        tuple val(name), file(fasta)
    output:
        tuple val(name), file("${name}_filtered.fa")
    script:
        """
        seqkit seq -m ${params.filter} ${fasta} > ${name}_filtered.fa
        """
}