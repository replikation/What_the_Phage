process chromomap_parser {
    publishDir "${params.output}/${name}/hmm/chromomap_filter", mode: 'copy'
    label 'noDocker'

    input:
    tuple val(name), file(positive_contigs_list)
    tuple val(name), file(hmmscan_results)
    tuple val(name), file(prodigal_out)

    output: 
    tuple val(name), file("chromosomefile.tbl"), file("annotationfile.tbl")
    
    script:
    """
    head ${hmmscan_results} >headfile.tbl
    prepare_hmmscan_for_chromomap.sh -c ${positive_contigs_list} -p ${prodigal_out} -a ${hmmscan_results}

    """
}