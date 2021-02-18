process checkV {
        publishDir "${params.output}/${name}/${category}", mode: 'copy'
        errorStrategy 'ignore'
        label 'checkV'
    input:
        tuple val(name), val(category), path(fasta)
        file(database)
    output:
        tuple val(name), file("${name}_quality_summary.tsv"), file("negative_result_${name}.txt") optional true
    script:
        """
        checkv completeness ${fasta} -d ${database} -t ${task.cpus} results #2> /dev/null 
        checkv repeats ${fasta} results #2> /dev/null
        checkv contamination ${fasta} -d ${database} -t ${task.cpus} results #2> /dev/null
        checkv quality_summary ${fasta}  results #2> /dev/null
        cp results/quality_summary.tsv ${name}_quality_summary.tsv #2> /dev/null
        """
}