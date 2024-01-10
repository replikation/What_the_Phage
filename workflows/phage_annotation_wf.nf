include { pvog_DB; vogtable_DB } from './process/phage_annotation/download_pvog_DB'
//include { vogtable_DB } from './process/phage_annotation/download_pvog_DB'
include { prodigal } from './process/phage_annotation/prodigal'
include { hmmscan } from './process/phage_annotation/hmmscan'
include { chromomap_parser } from './process/phage_annotation/chromomap_parser'
include { chromomap } from './process/phage_annotation/chromomap'

workflow phage_annotation_wf {
    take:   fasta_and_tool_results
    main:
           // Input for custom annotation database
           if (params.annotation_db) { annotation_custom_db_ch = Channel
                                            .fromPath( params.annotation_db, checkIfExists: true)
                                            .view()}
            // map input for prodigal
            fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}

            // Database for hmmscan
            pvog_DB()
            vogtable_DB()

            //annotation-process
            prodigal(fasta)
            if (!params.annotation_db) {hmmscan(prodigal.out, pvog_DB.out)}
            else {hmmscan(prodigal.out, annotation_custom_db_ch)}         
            chromomap_parser(fasta.join(hmmscan.out), vogtable_DB.out)
            chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))

            annotationtable_markdown_input = chromomap_parser.out.annotationfile_combined_ch

    emit: annotationtable_markdown_input

}


// chromomap_parser(
            //         fasta.join(hmmscan.out), vog_table)

            // chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))