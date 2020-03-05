process chromomap_parser {
    publishDir "${params.output}/${name}/hmm/chromomap_filter", mode: 'copy'
    label 'noDocker'

    input:
    tuple val(name), file(positive_contigs_list)
    tuple val(name), file(hmmscan_results)

    output: 
    tuple val(name), file("chromosomefile.tbl"), file("annotationfile.tbl"), file("headfile.tbl")
    script:
    """
    head ${hmmscan_results} >headfile.tbl
    prepare_hmmscan_for_chromomap.sh -c ${positive_contigs_list} -a ${hmmscan_results}

    """
}