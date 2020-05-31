process checkV {
        publishDir "${params.output}/${name}/"
        validExitStatus 1
        label 'checkV'
    input:
        tuple val(name), path(fasta)
        file(database)
    output:
        tuple val(name), file("${name}_quality_summary.tsv"), file("negative_result_${name}.txt") optional true
    script:
        """        
        checkv completeness ${fasta} -d ${database} -t ${task.cpus} results
        checkv repeats ${fasta} results
        checkv contamination ${fasta} -d ${database} -t ${task.cpus} results
        checkv quality_summary ${fasta}  results
        cp results/quality_summary.tsv ${name}_quality_summary.tsv
        exit 1
        if [ exit 1 ] then; 
            touch negative_result_${name}.txt
            echo "sorry..... nothing found" >> negative_result_${name}.txt
        fi
        """
}