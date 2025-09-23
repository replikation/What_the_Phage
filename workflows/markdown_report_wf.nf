include { markdown_preparation } from './process/markdown_report/markdown_preparation'
include { upsetr_report } from './process/markdown_report/upsetr_report.nf'
include { heatmap_table_report } from './process/markdown_report/heatmap_table_report.nf'
include { sample_report } from './process/markdown_report/sample_report.nf'
include { summary } from './process/markdown_report/summary_report.nf'
include { checkV_report } from './process/markdown_report/checkV_report.nf'
include { annotation_table_report } from './process/markdown_report/annotation_table_report.nf'
include { taxonomic_classification_report } from './process/markdown_report/taxonomic_classification_report.nf'

workflow markdown_report_wf {
    take:   
            identify_input
            annotation_taxonomy_input
            checkV_file

    main:                          
        identify_input.view()
        annotation_taxonomy_input.view()
        checkV_file.view()

        // map correct iputs from workflow control channels
        // wha happens if channel is empty ? --- : null
            upsetR_file = identify_input.map { it -> [it[0], it[1]] }
            heatmap_overview_file = identify_input.map { it -> [it[0] , it[2]]}
            annotationtable = annotation_taxonomy_input.map { it -> it[[0] , it[1]]}
            taxonomic_classification_file= annotation_taxonomy_input.map { it -> it[[0] , it[2]]}
            

        // markdown_preparation(heatmap_overview_file, annotationtable, checkV_file)
        
        // create markdown report
        // 0 load reports
        // toolreports/subtabs
            logo_channel=Channel.fromPath(workflow.projectDir + "/figures/logo-wtp_small.png", checkIfExists: true)
           



        // approach: channel empty, no process is triggers
        // choose report based on input flag
        /* 
        SAMPLE REPORTS
        >> Step 1. add the rmarkdown template here vvv (below this comment)
        */
            checkV_quality_table            = params.identify || params.annotate_taxonomy  ||  params.prophage ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/checkV_quality_table.Rmd", checkIfExists: true) : Channel.empty()
            upsetRreport                    = params.identify || params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/UpsetR.Rmd", checkIfExists: true) : Channel.empty()
            heatmap_tablereport             = params.identify || params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/Heatmap_table.Rmd", checkIfExists: true) : Channel.empty()
            annotation_table                = params.annotate_taxonomy ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/annotation_table.Rmd", checkIfExists: true) : Channel.empty()
            taxonomic_classification_table  = params.annotate_taxonomy ||  params.end_to_end ? Channel.fromPath(workflow.projectDir + "/submodule_report/taxonomic_classification.Rmd", checkIfExists: true) : Channel.empty()
            
            sampleheaderreport              = Channel.fromPath(workflow.projectDir + "/submodule_report/sampleheader.Rmd", checkIfExists: true)
            report                          = Channel.fromPath(workflow.projectDir + "/submodule_report/Report.Rmd", checkIfExists: true)


        // Step 2. create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
        //  collect tool reports PER sample (add new via .mix(NAME_report.out))
        

            samplereportinput =  upsetr_report  (upsetR_file.combine            (upsetRreport))
                                .mix            (checkV_report                  (checkV_file.combine(checkV_quality_table)))
                                .mix            (heatmap_table_report           (heatmap_overview_file.combine(heatmap_tablereport)))
                                .mix            (annotation_table_report        (annotationtable.combine(annotation_table)))
                                .mix            (taxonomic_classification_report(taxonomic_classification_file.combine(taxonomic_classification_table)))
                                .groupTuple(by: 0)
                                .map{it -> tuple (it[0],it[1],it[2].flatten())}
                                
            sample_report(samplereportinput.combine(sampleheaderreport))


        // 3 sumarize sample reports
            summary(sample_report.out.flatten().collect(), report, logo_channel)


            // // STD WORKFLOW AND --IDENTIFY
            // if (params.fasta && !params.identify && !params.annotate && !params.setup  || params.fasta && params.identify && !params.annotate && !params.setup ) { 
            //     checkV_quality_table=Channel.fromPath(workflow.projectDir + "/submodule_report/checkV_quality_table.Rmd", checkIfExists: true)
            //     upsetRreport=Channel.fromPath(workflow.projectDir + "/submodule_report/UpsetR.Rmd", checkIfExists: true)
            //     heatmap_tablereport=Channel.fromPath(workflow.projectDir + "/submodule_report/Heatmap_table.Rmd", checkIfExists: true)
            // }
            
            // // STD WORKFLOW AND --ANNOTATE
            // if (params.fasta && !params.identify && !params.annotate_taxonomy && !params.setup  || params.fasta && !params.identify && params.annotate && !params.setup ) {  
            //     checkV_quality_table=Channel.fromPath(workflow.projectDir + "/submodule_report/checkV_quality_table.Rmd", checkIfExists: true)
            //     annotation_table=Channel.fromPath(workflow.projectDir + "/submodule_report/annotation_table.Rmd", checkIfExists: true)
            //     taxonomic_classification_table=Channel.fromPath(workflow.projectDir + "/submodule_report/taxonomic_classification.Rmd", checkIfExists: true)
            // }

            // // sample and summary report
            // sampleheaderreport=Channel.fromPath(workflow.projectDir + "/submodule_report/sampleheader.Rmd", checkIfExists: true)
            // report=Channel.fromPath(workflow.projectDir + "/submodule_report/Report.Rmd", checkIfExists: true)

        // 1 create reports for each tool and samples its: reportprocess(inputchannel.combine(rmarkdowntemplate))
        // für jednen subheader also upset heat toolagree...nen process
            // STD WORKFLOW AND --IDENTIFY
        //     if (params.fasta && !params.identify && !params.annotate_taxonomy && !params.setup  || params.fasta && params.identify && !params.annotate && !params.setup ) { 
        //         checkV_report(checkV_file.combine(checkV_quality_table))
        //         upsetr_report(upsetR_file.combine(upsetRreport))
        //         heatmap_table_report(heatmap_overview_file.combine(heatmap_tablereport))
        //     }

        //     // STD WORKFLOW AND --ANNOTATE
        //     if (params.fasta && !params.identify && !params.annotate_taxonomy && !params.setup  || params.fasta && !params.identify && params.annotate && !params.setup ) {  
        //         checkV_report(checkV_file.combine(checkV_quality_table))
        //         annotation_table_report(annotationtable.combine(annotation_table))  
        //         taxonomic_classification_report(taxonomic_classification_file.combine(taxonomic_classification_table))
        //     }



        // // 2 collect tool reports PER sample (add new via .mix(NAME_report.out))
        // // workflow dependent report --annotation / --identify  i think I need do it for every step 1.2.3. 
        // // hier 3 cases aufmachen std, identi, anno
        //     // STD
        //     if (params.fasta && !params.identify && !params.annotate_taxonomy && !params.setup ){
        //         samplereportinput =     upsetr_report.out
        //                             .mix(heatmap_table_report.out)
        //                             .mix(checkV_report.out)
        //                             .mix(annotation_table_report.out)
        //                             .mix(taxonomic_classification_report.out)
        //                             .groupTuple(by: 0)
        //                             .map{it -> tuple (it[0],it[1],it[2].flatten())}

        //         sample_report(samplereportinput.combine(sampleheaderreport))
        //     }
        //     // --IDENTIFY
        //     if (params.fasta && params.identify && !params.annotate_taxonomy && !params.setup ){
        //         samplereportinput =     upsetr_report.out
        //                             .mix(checkV_report.out)
        //                             .mix(heatmap_table_report.out)
        //                             .groupTuple(by: 0)
        //                             .map{it -> tuple (it[0],it[1],it[2].flatten())}

        //         sample_report(samplereportinput.combine(sampleheaderreport))
        //     }
        //     // --ANNOTATE
        //     if (params.fasta && !params.identify && params.annotate_taxonomy && !params.setup ){
        //         samplereportinput =     checkV_report.out
        //                             .mix(annotation_table_report.out)
        //                             .mix(taxonomic_classification_report.out)
        //                             .groupTuple(by: 0)
        //                             .map{it -> tuple (it[0],it[1],it[2].flatten())}

        //         sample_report(samplereportinput.combine(sampleheaderreport))
        //     }

        // // 3 sumarize sample reports
        //     summary(sample_report.out.flatten().collect(), report, logo_channel)

    emit:  report
}