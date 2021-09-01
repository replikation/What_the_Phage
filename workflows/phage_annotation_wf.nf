include { pvog_DB; vogtable_DB } from './process/phage_annotation/download_pvog_DB'
//include { vogtable_DB } from './process/phage_annotation/download_pvog_DB'
include { prodigal } from './process/phage_annotation/prodigal'
include { hmmscan } from './process/phage_annotation/hmmscan'
include { chromomap_parser } from './process/phage_annotation/chromomap_parser'
include { chromomap } from './process/phage_annotation/chromomap'

workflow phage_annotation_wf {
    take:   fasta_and_tool_results
    main:
           
            fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}
            //Databases 
            //Database for hmmscan
            // local storage via storeDir
            if (!params.cloudProcess) { pvog_DB(); db = pvog_DB.out }
            // cloud storage via db_preload.exists()
            if (params.cloudProcess) {
                db_preload = file("${params.databases}/pvogs/", type: 'dir')
                if (db_preload.exists()) { db = db_preload }
                else  { pvog_DB(); db = pvog_DB.out } 
            }
            //Vog table
            // local storage via storeDir
            if (!params.cloudProcess) { vogtable_DB(); db = vogtable_DB.out }
            // cloud storage via db_preload.exists()
            if (params.cloudProcess) {
                db_preload = file("${params.databases}/vog_table/VOGTable.txt")
                if (db_preload.exists()) { db = db_preload }
                else  { vogtable_DB(); db = vogtable_DB.out } 
            }
            //annotation-process
            prodigal(fasta)
            hmmscan(prodigal.out, pvog_DB.out)            
            chromomap_parser(fasta.join(hmmscan.out), vogtable_DB.out)
            chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))
            // fine granular heatmap ()
            //hue_heatmap(fasta_and_tool_results)
}


// chromomap_parser(
            //         fasta.join(hmmscan.out), vog_table)

            // chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))