include { markdown_preparation } from './process/markdown_report/markdown_preparation'

workflow markdown_report_wf {
    take:   
            upsetR_file
            heatmap_overview_file
            annotationtable
            checkV_file
            
            //report_templates

    main:                          
        // prepare tables for markdown
        //contig by tool  // category
            markdown_preparation(heatmap_overview_file, annotationtable, checkV_file)
        
        // create markdown report
/*         // 0 load reports
            // toolreports/subtabs
            UpsetR_report=Channel.fromPath(workflow.projectDir + "/submodule_report/UpsetR.Rmd", checkIfExists: true)
            Heatmap_table_report=Channel.fromPath(workflow.projectDir + "/submodule_report/Heatmap_table.Rmd", checkIfExists: true)
            //tool_agreements_category_report=Channel.fromPath(workflow.projectDir + "/submodule_report/tool_agreements_category.Rmd", checkIfExists: true)
            
            // sample and summary report
            sampleheader_report=Channel.fromPath(workflow.projectDir + "/submodule_report/sampleheader.Rmd", checkIfExists: true)
            report=Channel.fromPath(workflow.projectDir + "/submodule_report/Report.Rmd", checkIfExists: true)


        // 1 create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
            // für jednen subheader also upset heat toolagree...nen process

            upset_report(UpsetR_report.combine(upsetR_file))
            heatmap_table(Heatmap_table_report.combine(heatmap_overview_file))





            WTP_report(WTP_report_ch.combine(WTPreport))

        // 2 collect tool reports PER sample (add new via .mix(NAME_report.out))
            samplereportinput =     WTP_report.out
                                    .groupTuple(by: 0)
                                    .map{it -> tuple (it[0],it[1],it[2].flatten())}

            sample_report(samplereportinput.combine(sampleheaderreport))


        // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report)

    emit:  report
 */}