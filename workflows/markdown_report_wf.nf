include { markdown_preparation } from './process/markdown_report/markdown_preparation'

workflow markdown_report_wf {
    take:   //basefiles
            // collectfile
            overview_file
            annotationtable
            checkV_file
            
            //report_templates

    main:                          
        // prepare tables for markdown


        //overview_file.view()
        annotationtable.view()
        test = annotationtable.map {it -> tuple(it[0],it[1],it[2])}.view()
        //checkV_file.view()
            //contig by tool  // category
            markdown_preparation(overview_file, annotationtable, checkV_file)
        
        // create markdown report
/*         // 0 load reports
            // toolreports
            WTPreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/wtp.Rmd", checkIfExists: true)
            // sample and summary report
            sampleheaderreport=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/sampleheader.Rmd", checkIfExists: true)
            report=Channel.fromPath(workflow.projectDir + "/submodule/rmarkdown_reports/rmarkdown_reports/templates/Report.Rmd", checkIfExists: true)


        // 1 create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))

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