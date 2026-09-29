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
    include { annotation_wf }              from './workflows/annotation_wf/annotation_wf.nf'
    include { taxonomy_wf }                from './workflows/taxonomy_wf/taxonomy_wf.nf'
    include { prophage_wf }                from './workflows/prophage_wf/prophage_wf'
    include { host_wf }                    from './workflows/host_wf/host_wf'
    include { lifecycle_wf }               from './workflows/lifecycle_wf/lifecycle_wf'
    include { report_wf }                  from './workflows/report_wf/report_wf'
    


workflow {

    main:
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

    
        fasta_input_ch = params.fasta && params.fasta != true ? 
                    Channel.fromPath( params.fasta, checkIfExists: true)
                        .map { file -> tuple(file.baseName, file) } :null

//get-citation-file for results
        citation = Channel.fromPath(workflow.projectDir + "/docs/Citations.bib").collectFile(storeDir: params.output + "/literature")





/************************** 
* WtP setup
**************************/

    if ( params.setup ) { setup_wf() }
    else {
    if (workflow.profile.contains('test') && !workflow.profile.contains('smalltest')) { test_wf_out = get_test_data_wf(); fasta_input_ch = test_wf_out.fasta }
    if (workflow.profile.contains('smalltest') ) 
        { fasta_input_ch = Channel.fromPath(workflow.projectDir + "/test-data/all_pos_phage.fa", checkIfExists: true).map { file -> tuple(file.simpleName, file) } }
    }
/************************** 
* worflow flow control
**************************/

// validate Input
    input_validation_wf(fasta_input_ch)

    if ( params.identify || params.annotation || params.end_to_end ) { checkV_wf(input_validation_wf.out.fasta) }
    if ( params.identify || params.end_to_end ) { identification_wf(input_validation_wf.out.fasta) }
    if ( params.annotation || params.end_to_end ) { annotation_wf(input_validation_wf.out.fasta, checkV_wf.out.checkv) }
    if ( params.taxonomy || params.end_to_end ) { taxonomy_wf(input_validation_wf.out.fasta) }
    if ( params.prophage || params.end_to_end ) { prophage_wf(input_validation_wf.out.fasta) }
    if ( params.host || params.end_to_end ) { host_wf(input_validation_wf.out.fasta) }
    if ( params.lifecycle || params.end_to_end ) { lifecycle_wf(input_validation_wf.out.fasta) }
    //if ( params.safety || params.end_to_end ) { safety_wf(input_validation_wf.out.fasta) }




    // report_wf(identify_ch, annotate_taxonomy_ch, checkV_ch, prophage_ch, lifecycle_ch)
    report_wf(
        params.identify || params.end_to_end ? identification_wf.out.identify_report_input : Channel.empty(),
        params.annotation || params.end_to_end ? annotation_wf.out.annotation_report_input : Channel.empty(),
        params.taxonomy || params.end_to_end ? taxonomy_wf.out.taxonomy_report_input : Channel.empty(),
        params.identify || params.annotation || params.end_to_end ? checkV_wf.out.checkv : Channel.empty(),
        params.prophage || params.end_to_end ? prophage_wf.out.prophage_report_input : Channel.empty(),
        params.host || params.end_to_end ? host_wf.out.host_report_input : Channel.empty(),
        params.lifecycle || params.end_to_end ? lifecycle_wf.out.lifecycle_results : Channel.empty()
    )

    publish:
    input_fasta                 = input_validation_wf.out.input_fasta
    checkv                      = params.identify || params.annotation || params.end_to_end ? checkV_wf.out.checkv : Channel.empty()
    checkv_raw                  = params.identify || params.annotation || params.end_to_end ? checkV_wf.out.checkv_raw : Channel.empty()
    identify_raw                = params.identify || params.end_to_end ? identification_wf.out.identify_raw : Channel.empty()
    identified_contigs          = params.identify || params.end_to_end ? identification_wf.out.identified_contigs : Channel.empty()
    upsetr                      = params.identify || params.end_to_end ? identification_wf.out.upsetr : Channel.empty()
    tool_agreements             = params.identify || params.end_to_end ? identification_wf.out.tool_agreements : Channel.empty()
    phabox2_identify            = params.identify || params.end_to_end ? identification_wf.out.phabox2_identify : Channel.empty()
    annotation_filter_too_strict = params.annotation || params.end_to_end ? annotation_wf.out.annotation_filter_too_strict : Channel.empty()
    annotation_hmm              = params.annotation || params.end_to_end ? annotation_wf.out.annotation_hmm : Channel.empty()
    annotation_prodigal         = params.annotation || params.end_to_end ? annotation_wf.out.annotation_prodigal : Channel.empty()
    annotation_chromomap        = params.annotation || params.end_to_end ? annotation_wf.out.annotation_chromomap : Channel.empty()
    annotation_pharokka         = params.annotation || params.end_to_end ? annotation_wf.out.annotation_pharokka : Channel.empty()
    annotation_phabox2          = params.annotation || params.end_to_end ? annotation_wf.out.annotation_phabox2 : Channel.empty()
    annotation_genomad          = params.annotation || params.end_to_end ? annotation_wf.out.annotation_genomad : Channel.empty()
    annotation_compare          = params.annotation || params.end_to_end ? annotation_wf.out.annotation_compare : Channel.empty()
    annotation_tables           = params.annotation || params.end_to_end ? annotation_wf.out.annotation_tables : Channel.empty()
    taxonomy_sourmash           = params.taxonomy || params.end_to_end ? taxonomy_wf.out.taxonomy_sourmash : Channel.empty()
    taxonomy_genomad            = params.taxonomy || params.end_to_end ? taxonomy_wf.out.taxonomy_genomad : Channel.empty()
    taxonomy_phabox2            = params.taxonomy || params.end_to_end ? taxonomy_wf.out.taxonomy_phabox2 : Channel.empty()
    taxonomy_taxmyphage         = params.taxonomy || params.end_to_end ? taxonomy_wf.out.taxonomy_taxmyphage : Channel.empty()
    taxonomy_combined           = params.taxonomy || params.end_to_end ? taxonomy_wf.out.taxonomy_combined : Channel.empty()
    prophage_genomad            = params.prophage || params.end_to_end ? prophage_wf.out.prophage_genomad_ch : Channel.empty()
    prophage_phabox2_tables     = params.prophage || params.end_to_end ? prophage_wf.out.prophage_phabox2_tables_ch : Channel.empty()
    prophage_phabox2_fa         = params.prophage || params.end_to_end ? prophage_wf.out.prophage_phabox2_fa_ch : Channel.empty()
    prophage_phigaro            = params.prophage || params.end_to_end ? prophage_wf.out.prophage_phigaro_ch : Channel.empty()
    prophage_virsorter2         = params.prophage || params.end_to_end ? prophage_wf.out.prophage_virsorter2_ch : Channel.empty()
    host_phabox2                = params.host || params.end_to_end ? host_wf.out.phabox2_host_ch : Channel.empty()
    iphop                       = params.host || params.end_to_end ? host_wf.out.iphop_ch : Channel.empty()
    lifecycle_phabox2           = params.lifecycle || params.end_to_end ? lifecycle_wf.out.lifecycle_phabox2_ch : Channel.empty()
    lifecycle_bacphlip          = params.lifecycle || params.end_to_end ? lifecycle_wf.out.lifecycle_bacphlip_ch : Channel.empty()
    lifecycle_tables            = params.lifecycle || params.end_to_end ? lifecycle_wf.out.lifecycle_results : Channel.empty()
    report_html                 = report_wf.out.report_html
    json_report                 = report_wf.out.json_report
    test_files                  = (workflow.profile.contains('test') && !workflow.profile.contains('smalltest')) ? test_wf_out.test_files : Channel.empty()

    onComplete:
        if (!params.setup) {
            progressBar(workflow)
            log.info ( workflow.success ? "\nDone! Results are stored here --> $params.output \nThank you for using What the Phage\n \nPlease cite us: https://doi.org/10.1101/2020.07.24.219899 \
                                        \n\nPlease also cite the other tools we use in our workflow --> $params.output/literature \n" : "Oops .. something went wrong" )
        }

// workflow bracket    
}

output {
    input_fasta { path { name, f -> "${name}/Input_fasta/" } }
    checkv { path { name, f -> "${name}/CheckV/" } }
    checkv_raw { path { name, f -> "${name}/raw_data/" } }
    identify_raw { path { name, f -> "${name}/raw_data/" } }
    identified_contigs { path { name, f -> "${name}/identified_contigs_by_tools/" } }
    upsetr { path { name, f -> "${name}/" } }
    tool_agreements { path { name, f -> "${name}/tool_agreements_per_contig/" } }
    phabox2_identify { path { name, f -> "${name}/phabox2/" } }
    annotation_filter_too_strict { path { name, f -> "${name}/annotation_results/" } }
    annotation_hmm { path { name, f1, f2 -> "${name}/raw_data/hmm/" } }
    annotation_prodigal { path { name, f -> "${name}/raw_data/prodigal_out/" } }
    annotation_chromomap { path { name, f -> "${name}/annotation_results/" } }
    annotation_pharokka { path { name, f -> "${name}/annotation_results/pharokka/" } }
    annotation_phabox2 { path { name, f -> "${name}/annotation_results/phabox2/" } }
    annotation_genomad { path { name, f -> "${name}/annotation_results/genomad/" } }
    annotation_compare { path { name, f -> "${name}/annotation_results/summary/" } }
    annotation_tables { path { name, f -> "${name}/annotation_results/" } }
    taxonomy_sourmash { path { name, f -> "${name}/taxonomic-classification/sourmash/" } }
    taxonomy_genomad { path { name, f -> "${name}/annotation_results/genomad/" } }
    taxonomy_phabox2 { path { name, f -> "${name}/taxonomic-classification/phabox2/" } }
    taxonomy_taxmyphage { path { name, f -> "${name}/taxonomic-classification/taxmyphage/" } }
    taxonomy_combined { path { name, f -> "${name}/taxonomic-classification/taxonomy_results_combined/" } }
    prophage_genomad { path { name, f -> "${name}/prophage/genomad/" } }
    prophage_phabox2_tables { path { name, f1, f2 -> "${name}/prophage/phabox2/" } }
    prophage_phabox2_fa { path { name, f -> "${name}/prophage/phabox2/" } }
    prophage_phigaro { path { name, f -> "${name}/prophage/phigaro/" } }
    prophage_virsorter2 { path { name, f -> "${name}/prophage/virsorter2/" } }
    host_phabox2 { path { name, f -> "${name}/host_prediction/phabox2_host/" } }
    iphop { path { name, f -> "${name}/prophage/genomad/" } }
    lifecycle_phabox2 { path { name, f -> "${name}/host_lifecycle/phabox2/" } }
    lifecycle_bacphlip { path { name, f -> "${name}/host_lifecycle/bacphlip/" } }
    lifecycle_tables { path { name, f -> "${name}/annotation_results/" } }
    report_html { path 'report' }
    json_report { path { name, f -> 'report' } }
test_files { path 'test-git' }
}
