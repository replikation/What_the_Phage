process contigs_by_tools {
    publishDir "${params.output}/${name}/tool_agreements_per_contig", mode: 'copy', pattern: "*.tsv"
    publishDir "${params.output}/${name}/tool_agreements_per_contig", mode: 'copy', pattern: "tool_agreements/*"
    label 'ubuntu'
    input:
        tuple val(name), path(files)
    output:
        tuple val(name), path("contig_tool_p-value_overview.tsv"), emit: overview_ch optional true
        tuple val(name), path("tools_used_for_phage_prediction.tsv"), emit: tools_used_ch optional true
        tuple val(name), path("toolagreement_per_contig.tsv"), emit: tool_agreements_per_contig_ch optional true
        tuple val(name), path("tool_agreements/*"), emit: tool_agreements_fasta_ch optional true 
    script:
        """
        contig_by_tool_count.sh 
        """
      stub:
        """
        touch contig_tool_p-value_overview.tsv
        touch tools_used_for_phage_prediction.txt
        touch toolagreement_per_contig.tsv
        echo "contig    p_value    tool" >> toolagreement_per_contig.tsv
        echo "abc_123    0.5    mikefinder" >> toolagreement_per_contig.tsv
        mkdir tool_agreements/
        touch tool_agreements/stub.tsv
        """        
}