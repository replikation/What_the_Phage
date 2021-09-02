process checkV {
        publishDir "${params.output}/${name}/", mode: 'copy'
        errorStrategy 'ignore'
        label 'checkV'
    input:
        tuple val(name), path(fasta)
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
    stub:
        """
        mkdir negative_result_${name}.txt
        echo "contig_id	contig_length	genome_copies	gene_count	viral_genes	host_genes	checkv_quality	miuvig_quality	completeness	completeness_method	contamination	provirus	termini	warnings" > ${name}_quality_summary.tsv
        echo "pos_phage_0	146647	1.0	243	141	1	High-quality	High-quality	97.03	AAI-based	0.0	No" >> ${name}_quality_summary.tsv   
        """
}