process score_based_chunking {
    label 'samtools'
        publishDir "${params.output}/${name}/phages-highly_likely", mode: 'copy', pattern: "contigs/highly_likely_contigs.fasta"
        publishDir "${params.output}/${name}/phages-likely", mode: 'copy', pattern: "contigs/likely_contigs.fasta"
        publishDir "${params.output}/${name}/phages-unlikely", mode: 'copy', pattern: "contigs/unlikely_contigs.fasta"
        publishDir "${params.output}/${name}/phages-not_likely", mode: 'copy', pattern: "contigs/not_likely_contigs.fasta"
    input:
        tuple val(name), path(hmm_table), path(prodigal_out), path(fasta), path(tool_results)
        path(vog_table)
    output: 
        tuple val(name), val("phages-highly_likely"), path("contigs/highly_likely_contigs.fasta"), optional: true
        tuple val(name), val("phages-likely"), path("contigs/likely_contigs.fasta"), optional: true
        tuple val(name), val("phages-unlikely"), path("contigs/unlikely_contigs.fasta"), optional: true
        tuple val(name), val("phages-not_likely"), path("contigs/not_likely_contigs.fasta"), optional: true
    script:
        """
        score_chunking.sh ${fasta} ${task.cpus} "0.9" "0.6" "0.3"
        """
    stub:
        """
        mkdir contigs
        touch contigs/highly_likely_contigs.fasta
        touch contigs/likely_contigs.fasta
        touch contigs/unlikely_contigs.fasta
        touch contigs/not_likely_contigs.fasta

        ## phages-highly_likely=\$('1')
        ## phages-likely=\$('2')
        ## phages-unlikely=\$('3')
        ## phages-not_likely=\$('4')
        """
}

/*
annotation are available -> suggesting to modify scores based on clear phage genes (tail capsid)
providing checkV data to further influence score

*/