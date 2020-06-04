process chromomap_parser {
    publishDir "${params.output}/${name}/annotation_results", mode: 'copy'
    label 'noDocker'

    input:
    tuple val(name), path(positive_contigs_list), path(hmmscan_results), path(prodigal_out)
    path(vogtable)

    output: 
    tuple val(name), val("small"), path("small/chromosomefile.tbl"), path("small/annotationfile.tbl")
    tuple val(name), val("large"), path("large/chromosomefile.tbl"), path("large/annotationfile.tbl")
    script:
    """
    prepare_hmmscan_for_chromomap.sh -c ${positive_contigs_list} -p ${prodigal_out} -a ${hmmscan_results} -v ${vogtable}

    mkdir small large 
    awk '\$3 >= 99999' chromosomefile.tbl >> large/chromosomefile.tbl
    awk '\$3 < 99999' chromosomefile.tbl >> small/chromosomefile.tbl

    while read -r f1 f2 f3; do
        grep --no-messages -w "\$f1" annotationfile.tbl 1>> large/annotationfile.tbl || true
    done < large/chromosomefile.tbl

    while read -r f1 f2 f3; do
        grep --no-messages -w "\$f1" annotationfile.tbl 1>> small/annotationfile.tbl || true
    done < small/chromosomefile.tbl
    """
}