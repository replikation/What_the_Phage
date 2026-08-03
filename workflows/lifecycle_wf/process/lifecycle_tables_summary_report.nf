process lifecycle_tables_summary_report {
    publishDir "${params.output}/${name}/annotation_results/", mode: 'copy'
    label 'template_r'

    input:
    tuple val(name), path(bed_files)

    output:
    tuple val(name), path("*_lifecycle_report_summary.tsv"), emit: lifecycle_tsv_ch , optional: true

    script:
    """
    lifecycle_report_summary.R ${name}_lifecycle_report_summary.tsv
    
    """

    stub:
    """
    touch ${name}_annotation_report_summary.tsv
    """
}
