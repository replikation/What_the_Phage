process prodigal_parser {
    label 'noDocker'
    //errorStrategy 'ignore'
    input:
        tuple val(name), path(contigs), path(hmmscan_results), path(prodigal_out)
        path(vogtable)
    output:
        tuple val(name), path("annotationfile_combined.tbl"), emit: annotationfile_combined_ch, optional: true
    script:
        """
        set -euxo pipefail

        # produce prodigal/pvog annotation table from prodigal faa + hmmscan results
        prepare_hmmscan_for_chromomap.sh -c ${contigs} -p ${prodigal_out} -a ${hmmscan_results} -v ${vogtable}

        # annotationfile.tbl holds the combined prodigal annotation; use it directly for the report
        touch annotationfile_combined.tbl
        if [ -f annotationfile.tbl ]; then
            mv annotationfile.tbl annotationfile_combined.tbl
        fi

        # zip for export
        tar -czf ${name}_prodigal_parser_output.tar.gz *.tbl
        """
    stub:
        """
        touch annotationfile_combined.tbl
        """
}