process contigs_by_tools {
    publishDir "${params.output}/${name}/tool_agreements_per_contig", mode: 'copy', pattern: "*.tsv"
    publishDir "${params.output}/${name}/tool_agreements_per_contig", mode: 'copy', pattern: "tool_agreements/*"
    label 'ubuntu'
    input:
        tuple val(name), path(files)
    output:
        tuple val(name), path("all_overview.tsv"), path("tools_used_for_phage_prediction.tsv"), path("toolagreement_per_contig.tsv"), path("tool_agreements/*") optional true

    script:
        """
        contig_by_tool_count.sh
        """
      stub:
        """
        touch all_overview.tsv
        touch tools_used_for_phage_prediction.txt
        toolagreement_per_contig.tsv

        """        
}