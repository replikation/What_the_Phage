include { markdown_preparation } from './process/markdown_report/markdown_preparation'
include { upsetr_report } from './process/markdown_report/upsetr_report.nf'
include { heatmap_table_report } from './process/markdown_report/heatmap_table_report.nf'
include { sample_report } from './process/markdown_report/sample_report.nf'
include { summary } from './process/markdown_report/summary_report.nf'
include { checkV_report } from './process/markdown_report/checkV_report.nf'
include { annotation_table_report } from './process/markdown_report/annotation_table_report.nf'







workflow markdown_report_wf {
    take:   
            upsetR_file //.svg
            heatmap_overview_file
            annotationtable
            checkV_file
    main:                          
        // prepare tables for markdown
        //contig by tool  // category

           // markdown_preparation(heatmap_overview_file, annotationtable, checkV_file)
        
        // create markdown report
        // 0 load reports
            // toolreports/subtabs
            // STD WORKFLOW AND --IDENTIFY
            if (params.fasta && !params.identify && !params.annotate && !params.setup  || params.fasta && params.identify && !params.annotate && !params.setup ) { 
                upsetRreport=Channel.fromPath(workflow.projectDir + "/submodule_report/UpsetR.Rmd", checkIfExists: true)
                heatmap_tablereport=Channel.fromPath(workflow.projectDir + "/submodule_report/Heatmap_table.Rmd", checkIfExists: true)
            }
            
            // STD WORKFLOW AND --ANNOTATE
            if (params.fasta && !params.identify && !params.annotate && !params.setup  || params.fasta && !params.identify && params.annotate && !params.setup ) {  
                checkV_quality_table=Channel.fromPath(workflow.projectDir + "/submodule_report/checkV_quality_table.Rmd", checkIfExists: true)
                annotation_table=Channel.fromPath(workflow.projectDir + "/submodule_report/annotation_table.Rmd", checkIfExists: true)
            }

            // sample and summary report
            sampleheaderreport=Channel.fromPath(workflow.projectDir + "/submodule_report/sampleheader.Rmd", checkIfExists: true)
            report=Channel.fromPath(workflow.projectDir + "/submodule_report/Report.Rmd", checkIfExists: true)

        // 1 create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
        // für jednen subheader also upset heat toolagree...nen process
            // STD WORKFLOW AND --IDENTIFY
            if (params.fasta && !params.identify && !params.annotate && !params.setup  || params.fasta && params.identify && !params.annotate && !params.setup ) { 
                upsetr_report(upsetR_file.combine(upsetRreport))
                heatmap_table_report(heatmap_overview_file.combine(heatmap_tablereport))
            }

            // STD WORKFLOW AND --ANNOTATE
            if (params.fasta && !params.identify && !params.annotate && !params.setup  || params.fasta && !params.identify && params.annotate && !params.setup ) {  
                checkV_report(checkV_file.combine(checkV_quality_table))
                annotation_table_report(annotationtable.combine(annotation_table))
            }



        // 2 collect tool reports PER sample (add new via .mix(NAME_report.out))
        // workflow dependent report --annotation / --identify  i think I need do it for every step 1.2.3. 
        // hier 3 cases aufmachen std, identi, anno
            // STD
            if (params.fasta && !params.identify && !params.annotate && !params.setup ){
                samplereportinput =     upsetr_report.out
                                    .mix(heatmap_table_report.out)
                                    .mix(checkV_report.out)
                                    .mix(annotation_table_report.out)
                                    .groupTuple(by: 0)
                                    .map{it -> tuple (it[0],it[1],it[2].flatten())}.view()

                sample_report(samplereportinput.combine(sampleheaderreport))
            }
            // --IDENTIFY
            if (params.fasta && params.identify && !params.annotate && !params.setup ){
                samplereportinput =     upsetr_report.out
                                    .mix(heatmap_table_report.out)
                                    .groupTuple(by: 0)
                                    .map{it -> tuple (it[0],it[1],it[2].flatten())}.view()

                sample_report(samplereportinput.combine(sampleheaderreport))
            }
            // --ANNOTATE
            if (params.fasta && !params.identify && params.annotate && !params.setup ){
                samplereportinput =     checkV_report.out
                                    .mix(annotation_table_report.out)
                                    .groupTuple(by: 0)
                                    .map{it -> tuple (it[0],it[1],it[2].flatten())}.view()

                sample_report(samplereportinput.combine(sampleheaderreport))
            }

        // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report)

    emit:  report
}