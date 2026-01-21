process annotation_tables_summary_report {
    publishDir "${params.output}/${name}/annotation_results/", mode: 'copy'
    label 'r_template'

    input:
    tuple val(name), path(bed_files)

    output:
    tuple val(name), path("*_annotation_report_summary.tsv"), emit: annotation_tsv_ch , optional: true

    script:
    """
    annotation_report_summary.R ${name}_annotation_report_summary.tsv
    
    """

    stub:
    """
    touch ${name}_annotation_report_summary.tsv
    """
}
