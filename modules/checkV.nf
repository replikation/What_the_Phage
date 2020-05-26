process checkV {
        label 'checkV'
    input:
        tuple val(name), path(fasta)
        file(database)
    output:
        file("*.csv")
    script:
        """        
        checkv ${fasta} -d ${database} -t ${tasks.cpus} results
        checkv repeats ${fasta} results
        checkv contamination ${fasta} -d ${database} -t ${tasks.cpus} results
        quality_summary ${fasta}  results
        """
}