include { markdown_preparation } from './process/markdown_report/markdown_preparation'
include { upsetr_report } from './process/markdown_report/upsetr_report.nf'
include { heatmap_table_report } from './process/markdown_report/heatmap_table_report.nf'
include { sample_report } from './process/markdown_report/sample_report.nf'
include { summary } from './process/markdown_report/summary_report.nf'
include { checkV_report } from './process/markdown_report/checkV_report.nf'
include { annotation_table_report } from './process/markdown_report/annotation_table_report.nf'
include { taxonomic_classification_report } from './process/markdown_report/taxonomic_classification_report.nf'
include { prophage_report } from './process/markdown_report/prophage_report.nf'

workflow markdown_report_wf {
    take:   
            identify_input
            annotation_report_input
            taxonomy_report_input
            checkV_file
            prophages

    main:                          
            // map correct iputs from workflow control channels
            // wha happens if channel is empty ? --- : null
          identify_input.view()
          annotation_report_input.view()
          taxonomy_report_input.view()
          checkV_file.view()
          prophages.view()



            upsetR_file = identify_input.map { it -> tuple(it[0], it[1]) }
            heatmap_overview_file = identify_input.map { it -> tuple(it[0], it[2])}
            
            // markdown_preparation(heatmap_overview_file, annotationtable, checkV_file)
            
            // create markdown report
            // Step0 load reports
            // toolreports/subtabs
           
         
            // SAMPLE REPORTS
            // Step 1. add the rmarkdown template here vvv (below this comment)
            logo_channel                    = Channel.fromPath(workflow.projectDir + "/figures/logo-wtp_small.png", checkIfExists: true)
            checkV_quality_table            = params.identify || params.annotate_taxonomy  ||  params.prophage ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/checkV_quality_table.Rmd", checkIfExists: true) : Channel.empty()
            upsetRreport                    = params.identify || params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/UpsetR.Rmd", checkIfExists: true) : Channel.empty()
            heatmap_tablereport             = params.identify || params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/Heatmap_table.Rmd", checkIfExists: true) : Channel.empty()
            annotation_table                = params.annotate_taxonomy ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/annotation_table.Rmd", checkIfExists: true) : Channel.empty()
            taxonomic_classification_table  = params.annotate_taxonomy ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/taxonomic_classification.Rmd", checkIfExists: true) : Channel.empty()
            prophage_table                  = params.prophage          ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/prophage_report.Rmd", checkIfExists: true) : Channel.empty()
            
            sampleheaderreport              = Channel.fromPath(workflow.projectDir + "/submodule_report/sampleheader.Rmd", checkIfExists: true)
            report                          = Channel.fromPath(workflow.projectDir + "/submodule_report/Report.Rmd", checkIfExists: true)


            // Step 2. create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
            //  collect tool reports PER sample (add new via .mix(NAME_report.out))
        

            samplereportinput =  upsetr_report  (upsetR_file.combine            (upsetRreport))
                                .mix            (checkV_report                  (checkV_file.combine(checkV_quality_table)))
                                .mix            (heatmap_table_report           (heatmap_overview_file.combine(heatmap_tablereport)))
                                .mix            (annotation_table_report        (annotation_report_input.combine(annotation_table)))
                                .mix            (taxonomic_classification_report(taxonomy_report_input.combine(taxonomic_classification_table)))
                                .mix            (prophage_report(prophages.combine(prophage_table)))
                                .groupTuple(by: 0)
                                .map{it -> tuple (it[0],it[1],it[2].flatten())}
            
            sample_report(samplereportinput.combine(sampleheaderreport))


            // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report, logo_channel)



    emit:  report
}