#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* Nextflow -- What the Phage
* Author: @github: mult1fractal & christian.jena@gmail.com
*/

    include { helpMSG; defaultMSG; progressBar }   from './libs/messages.nf'
    include { get_test_data_wf }           from './workflows/get_test_data_wf'
    include { setup_wf }                   from './workflows/setup_wf'
    include { input_validation_wf }        from './workflows/input_validation_wf/input_validation_wf'
    include { checkV_wf }                  from './workflows/quality_control_wf/checkV_wf'
    include { identification_wf }          from './workflows/phage_identification_wf/identification_wf'
    include { annotation_taxonomy_wf }     from './workflows/annotation_and_taxonomy_wf/annotation_taxonomy_wf.nf'
    include { prophage_wf }                from './workflows/prophage_wf/prophage_wf'
    include { host_prediction_wf }         from './workflows/host_prediction_wf/host_prediction_wf'
    // include { lifecycle_wf }            from './workflows/host_lifecycle_wf/host_lifecycle_wf'
    include { markdown_report_wf }         from './workflows/markdown_report_wf'
    include { quarto_report_wf }           from './workflows/quarto_report_wf'
    


workflow {

        params.help             ? { exit 0, helpMSG() }()       : defaultMSG()

/************* 
* ERROR HANDLING
*************/
        // profiles
        if ( workflow.profile == 'standard' ) { exit 1, "NO VALID EXECUTION PROFILE SELECTED, use e.g. [-profile local,docker]" }

        if (
            workflow.profile.contains('singularity') ||
            workflow.profile.contains('ukj_cloud') ||
            workflow.profile.contains('stub') ||
            workflow.profile.contains('docker')
            ) { "engine selected" }
        else { exit 1, "No engine selected:  -profile EXECUTER,ENGINE" }

        if (
            workflow.profile.contains('local') ||
            workflow.profile.contains('test') ||
            workflow.profile.contains('smalltest') ||
            workflow.profile.contains('ebi') ||
            workflow.profile.contains('slurm') ||
            workflow.profile.contains('lsf') ||
            workflow.profile.contains('ukj_cloud') ||
            workflow.profile.contains('stub') ||
            workflow.profile.contains('git_action')
            ) { "executer selected" }
        else { exit 1, "No executer selected:  -profile EXECUTER,ENGINE" }

        // params tests
        if (!params.setup && !workflow.profile.contains('test') && !workflow.profile.contains('smalltest')) {
            if ( !params.fasta && !params.fastq ) {
                exit 1, "input missing, use [--fasta] "}
            if ( params.ma && params.mp && params.vf && params.vs && params.pp && params.dv && params.sm && params.vn && params.vb && params.ph && params.vs2 && params.sk ) {
                exit 0, "What the... you deactivated all the tools"}
        }

        if ( workflow.profile.contains('singularity') ) {
            println ""
            println "\033[0;33mWARNING: Singularity image building sometimes fails!"
            println "Multiple resumes (-resume) and --max_cores 1 --cores 1 for local execution might help.\033[0m\n"
        }

/************* 
* INPUT HANDLING
*************/

    
        fasta_input_ch = params.fasta ? 
                    Channel.fromPath( params.fasta, checkIfExists: true)
                        .map { file -> tuple(file.baseName, file) } :null

//get-citation-file for results
        citation = Channel.fromPath(workflow.projectDir + "/docs/Citations.bib").collectFile(storeDir: params.output + "/literature")





/************************** 
* WtP setup
**************************/

    if ( params.setup ) { setup_wf() }
    else {
    if (workflow.profile.contains('test') && !workflow.profile.contains('smalltest')) { fasta_input_ch = get_test_data_wf() }
    if (workflow.profile.contains('smalltest') ) 
        { fasta_input_ch = Channel.fromPath(workflow.projectDir + "/test-data/all_pos_phage.fa", checkIfExists: true).map { file -> tuple(file.simpleName, file) } }
    }
/************************** 
* worflow flow control
**************************/

    // validate Input
    input_validation_wf(fasta_input_ch)



    // Workflow handling based on flag
    // these channels ar "datastream channels and cannot be viewed with view()"

    identify_ch             = params.identify || params.end_to_end ? identification_wf(input_validation_wf.out) : Channel.empty()
    checkV_ch               = params.identify || params.annotate_taxonomy  || params.end_to_end ? checkV_wf(input_validation_wf.out) : Channel.empty()
    annotate_taxonomy_ch    = params.annotate_taxonomy ||  params.end_to_end ? annotation_taxonomy_wf(input_validation_wf.out, checkV_ch) : Channel.empty()
    prophage_ch             = params.prophage ||  params.end_to_end ? prophage_wf(input_validation_wf.out) : Channel.empty()
    host_ch                 = params.host ||  params.end_to_end ? host_prediction_wf(input_validation_wf.out) : Channel.empty()
    // lifecycle_ch         = params.lifecycle ||  params.end_to_end ? lifecycle_wf(input_validation_wf.out) : Channel.empty()
    // phage host interaction model: https://github.com/bioinfodlsu/phage-host-prediction
 


    if (params.quarto_report) {
        quarto_report_wf(identify_ch, annotate_taxonomy_ch.annotation_markdown_input.join(annotate_taxonomy_ch.taxonomy_markdown_input), checkV_ch, prophage_ch.prophage_report_input)
    } else {
        markdown_report_wf(identify_ch, annotate_taxonomy_ch.annotation_markdown_input, annotate_taxonomy_ch.taxonomy_markdown_input, checkV_ch, prophage_ch.prophage_report_input)
    }
    
}



    if (!params.setup) {
        workflow.onComplete { 
            progressBar(workflow)
            log.info ( workflow.success ? "\nDone! Results are stored here --> $params.output \nThank you for using What the Phage\n \nPlease cite us: https://doi.org/10.1101/2020.07.24.219899 \
                                          \n\nPlease also cite the other tools we use in our workflow --> $params.output/literature \n" : "Oops .. something went wrong" )
        }
    }