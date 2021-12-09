process chromomap_parser {
    publishDir "${params.output}/${name}/annotation_results", mode: 'copy'
    label 'noDocker'
    input:
        tuple val(name), path(contigs), path(hmmscan_results), path(prodigal_out)

        path(vogtable)
    output: 
        tuple val(name), val("small"), path("small/chromosomefile.tbl"), path("small/annotationfile.tbl") optional true
        tuple val(name), val("large"), path("large/chromosomefile.tbl"), path("large/annotationfile.tbl") optional true
        tuple val(name), path("annotationfile_combined.tbl"), emit: annotationfile_combined_ch optional true
    script:
        """
        prepare_hmmscan_for_chromomap.sh -c ${contigs} -p ${prodigal_out} -a ${hmmscan_results} -v ${vogtable}

        mkdir small large 
        awk '\$3 >= 99999' chromosomefile.tbl >> large/chromosomefile.tbl
        awk '\$3 < 99999' chromosomefile.tbl >> small/chromosomefile.tbl

        while read -r f1 f2 f3; do
            grep --no-messages -w "\$f1" annotationfile.tbl 1>> large/annotationfile.tbl || true
        done < large/chromosomefile.tbl

        while read -r f1 f2 f3; do
            grep --no-messages -w "\$f1" annotationfile.tbl 1>> small/annotationfile.tbl || true
        done < small/chromosomefile.tbl

        ## create combined annotationfile for ez markdownreport
            ##need error handling?
        touch annotationfile_combined.tbl
        ## cat large/annotationfile.tbl small/annotationfile.tbl >> annotationfile_combined.tbl 2>/dev/null
        [ -f large/annotationfile.tbl ] && cat large/annotationfile.tbl >> annotationfile_combined.tbl
        [ -f small/annotationfile.tbl ] && cat small/annotationfile.tbl >> annotationfile_combined.tbl


        """
      stub:
        """
        mkdir small
        mkdir large
        
        touch small/chromosomefile.tbl
        touch small/annotationfile.tbl

        touch large/chromosomefile.tbl
        touch large/annotationfile.tbl
        """
}