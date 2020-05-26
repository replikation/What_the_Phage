process checkV {
        publishDir "${params.output}/${name}/"
        label 'checkV'
    input:
        tuple val(name), path(fasta)
        file(database)
    output:
        tuple val(name), file("${name}_quality_summary.tsv")
    script:
        """        
        checkv completeness ${fasta} -d ${database} -t ${task.cpus} results
        checkv repeats ${fasta} results
        checkv contamination ${fasta} -d ${database} -t ${task.cpus} results
        checkv quality_summary ${fasta}  results
        cp results/quality_summary.tsv ${name}_quality_summary.tsv
        """
}