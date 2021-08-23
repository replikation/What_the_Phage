process normalize_contig_size {
    label 'sourmash'
    input:
        tuple val(name), file(fasta)
    output:
        tuple val(name), file("${name}_fragments.fasta")
    script:
        """
        cut.py --size 3000 --genome ${fasta} --outfile ${name}_fragments.fasta
        """
    stub:
        """
        touch ${name}_fragments.fasta
        """
}

