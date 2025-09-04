include { pvog_DB; vogtable_DB } from './process/download_pvog_DB'
//include { vogtable_DB } from './process/phage_annotation/download_pvog_DB'
include { prodigal } from './process/prodigal'
include { hmmscan } from './process/hmmscan'
include { chromomap_parser } from './process/chromomap_parser'
include { chromomap } from './process/chromomap'
include { pharokka } from './process/pharokka'
include { pharokka_plotter } from './process/pharokka'
include { phabox2_annotation } from './process/phabox2_annotation'

workflow phage_annotation_wf {
    take:   fasta_and_tool_results
            checkv
    main:
           // Input for custom annotation database
           if (params.annotation_db) { annotation_custom_db_ch = Channel
                                            .fromPath( params.annotation_db, checkIfExists: true)
                                            }
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

            //annotation via pharokka
            if (params.pharokka) {pharokka(fasta) 
                                    plot_in= fasta
                                        .join( pharokka.out)
                                        .join( checkv) 
                                    pharokka_plotter(plot_in)
                                 }
            
            // annotation via phabox2
            // lol= checkv
            // lol.view()
            // fasta.view()
            phabox2_annotation(fasta)
            // phabox2_plot_annotation(phabox2_annotation.out, checkv)
            

    emit: annotationtable_markdown_input

}


// chromomap_parser(
            //         fasta.join(hmmscan.out), vog_table)

            // chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))