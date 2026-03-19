include { report } from './report.nf'
include { results_to_json } from './results_to_json.nf' 


workflow report_wf {
    take:   
            identify_report_input
            annotation_report_input
            taxonomy_report_input
            checkV_report_input
            prophages_report_input
            host_report_input
            lifecycle_report_input

    main:                          
        	prophages_report_input.view()

            // [all_pos_phage, /mnt/6tb_1/work/0a/9639ed58bf4af7beb3d217c6695fc6/upsetr.svg, /mnt/6tb_1/work/5b/a048465f3ee6c71181bc6240c7f66c/contig_tool_p-value_overview.tsv] 
            // identify_input.
           
            //   [all_pos_phage, /mnt/6tb_1/work/39/b4d12c0a558aebb6a907bb65698f1e/all_pos_phage_annotation_report_summary.tsv, /mnt/6tb_1/work/72/77acac6da34dff42b96acb9553d964/all_pos_phage_annotation_waffle_summary.svg]
            // annotation_report_input

            // [all_pos_phage, /mnt/6tb_1/work/6e/f58f1435a91bec4489bdf4da030201/all_pos_phage_taxonomy_sourmash.tsv, /mnt/6tb_1/work/95/d273ac529e0b1ba6611d814c2f97be/all_pos_phage_filtered_taxonomy_genomad.tsv]
            // taxonomy_report_input
            
            // [all_pos_phage, /mnt/6tb_1/work/a9/304aa5c6419ce84ab3b9d880f76b9c/all_pos_phage_quality_summary.tsv]
            // checkV_file

            // [all_pos_phage, /mnt/6tb_1/work/f1/ae80a6fbbcdfc75ab0c9c3b026c032/all_pos_phage_filtered_provirus.tsv, /mnt/6tb_1/work/59/f66399c3e94bf6ecbe26a8dfd299f0/all_pos_phage_contamination_prediction.tsv, /mnt/6tb_1/work/59/f66399c3e94bf6ecbe26a8dfd299f0/all_pos_phage_candidate_provirus.tsv, /mnt/6tb_1/work/c5/1e8dcda771d9fcf57c190e39900832/virsorter2.out/all_pos_phage_final-viral-score.tsv, /mnt/6tb_1/work/a9/2d6d932339b6b515437576828874cb/all_pos_phage_phigaro_prophage.tsv]
            // prophages

            // logo_channel                    = Channel.fromPath(workflow.projectDir + "/figures/logo-wtp_small.png", checkIfExists: true)
            // checkV_quality_table            = params.identify || params.annotate_taxonomy  ||  params.prophage ||  params.end_to_end : Channel.empty()
            // upsetRreport                    = params.identify || params.end_to_end : Channel.empty()
            // heatmap_tablereport             = params.identify || params.end_to_end : Channel.empty()
            // annotation_table                = params.annotate_taxonomy ||  params.end_to_end : Channel.empty()
            // taxonomic_classification_table  = params.annotate_taxonomy ||  params.end_to_end : Channel.empty()
            // prophage_table                  = params.prophage          ||  params.end_to_end : Channel.empty()


          //  identify_raw = identify_input.map { it -> tuple(it[0], it[2]) }
            report_input = identify_report_input
                            .mix(annotation_report_input)
                            .mix(taxonomy_report_input)
                            .mix(checkV_report_input)
                            .mix(prophages_report_input)
                            .mix(host_report_input)
                            .mix(lifecycle_report_input)
                        .groupTuple(by: 0)
                        .map { it -> [ it[0], it[1..-1].flatten().findAll { it != null } ] }
              
            report_input.view()

            results_to_json(report_input)
            
            report(results_to_json.out.map { it -> it[1] }.collect(), "${projectDir}/libs/report_template.html")

    emit:   
            report.out

            
}