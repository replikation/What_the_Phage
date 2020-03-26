process chromomap_parser {
    publishDir "${params.output}/${name}/hmm/chromomap_filter", mode: 'copy'
    label 'noDocker'

    input:
    tuple val(name), file(positive_contigs_list), file(hmmscan_results), file(prodigal_out)
    file(vogtable)

    output: 
    tuple val(name), file("chromosomefile.tbl"), file("annotationfile.tbl")
    
    script:
    """
   
    prepare_hmmscan_for_chromomap.sh -c ${positive_contigs_list} -p ${prodigal_out} -a ${hmmscan_results} -v ${vogtable}

    """
}