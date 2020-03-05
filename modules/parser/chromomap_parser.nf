process chromomap_parser {
    publishDir "${params.output}/${name}/hmm/chromomap_filter", mode: 'copy'
    label 'noDocker'

    input:
    tuple val(name), file(positive_contigs_list)
    file(hmmscan_results)
    output: 
    tuple val(name), file("chromosomefile.tbl"), file("annotationfile.tbl")
    script:
    """
    prepare_hmmscan_for_chromomap.sh -c ${positive_contigs_list} -a ${hmmscan_results}

    """
}