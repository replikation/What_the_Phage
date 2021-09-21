#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* Nextflow -- What the Phage
* Author: christian.jena@gmail.com
*/

/* 
Nextflow version check  
Format is this: XX.YY.ZZ  (e.g. 20.07.1)
change below
*/

XX = "20"
YY = "07"
ZZ = "1"

if ( nextflow.version.toString().tokenize('.')[0].toInteger() < XX.toInteger() ) {
println "\033[0;33mWtP requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}
else if ( nextflow.version.toString().tokenize('.')[1].toInteger() == XX.toInteger() && nextflow.version.toString().tokenize('.')[1].toInteger() < YY.toInteger() ) {
println "\033[0;33mWtP requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}

println "_____ _____ ____ ____ ___ ___ __ __ _ _ "
println "  __      _______________________ "
println " /  \\    /  \\__    ___/\\______   \\"
println " \\   \\/\\/   / |    |    |     ___/"
println "  \\        /  |    |    |    |    "
println "   \\__/\\  /   |____|    |____|    "
println "        \\/                        "
println "_____ _____ ____ ____ ___ ___ __ __ _ _ "

if (params.help) { exit 0, helpMSG() }

println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "WtP intended for Nextflow-version: 20.01.0"
println "Starting time: $nextflow.timestamp"
println "Workdir location [--workdir]:"
println "  $workflow.workDir"
println "Output location [--output]:"
println "  $params.output"
println "\033[2mDatabase location [--databases]:"
println "  $params.databases\u001B[0m"
if (workflow.profile.contains('singularity')) {
println "\033[2mSingularity cache location [--cachedir]:"
println "  $params.cachedir"
println "  "
println "\u001B[33m  WARNING: Singularity image building sometimes fails!"
println "  Please download all images first via --setup --cachedir IMAGE-LOCATION"
println "  Manually remove faulty images in $params.cachedir for a rebuild\u001B[0m"
}
if (params.annotate) { println "\u001B[33mSkipping phage identification for fasta files\u001B[0m" }
if (params.identify) { println "\u001B[33mSkipping phage annotation\u001B[0m" }
println " "
println "\033[2mCPUs to use: $params.cores, maximal CPUs to use: $params.max_cores\033[0m"
println " "

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
        exit 1, "input missing, use [--fasta] or [--fastq]"}
    if ( params.ma && params.mp && params.vf && params.vs && params.pp && params.dv && params.sm && params.vn && params.vb && params.ph && params.vs2 && params.sk ) {
        exit 0, "What the... you deactivated all the tools"}
}

/************* 
* INPUT HANDLING
*************/

// fasta input or via csv file, fasta input is deactivated if test profile is choosen
    if (params.fasta && params.list && !workflow.profile.contains('test') ) { fasta_input_ch = Channel
            .fromPath( params.fasta, checkIfExists: true )
            .splitCsv()
            .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
                }
    else if (params.fasta && !workflow.profile.contains('test') ) { fasta_input_ch = Channel
            .fromPath( params.fasta, checkIfExists: true)
            .map { file -> tuple(file.baseName, file) }
                }
    
//get-citation-file for results
    citation = Channel.fromPath(workflow.projectDir + "/docs/Citations.bib")
            .collectFile(storeDir: params.output + "/literature")

/************************** 
* Workflows to call
**************************/

include { input_validation_wf } from './workflows/input_validation_wf'
include { deepvirfinder_wf } from './workflows/deepvirfinder_wf.nf'
include { phigaro_wf } from './workflows/phigaro_wf'
include { seeker_wf } from './workflows/seeker_wf'
include { virfinder_wf } from './workflows/virfinder_wf'
include { virnet_wf } from './workflows/virnet_wf'
include { pprmeta_wf } from './workflows/pprmeta_wf'
include { metaphinder_wf } from './workflows/metaphinder_wf'
include { metaphinder_own_DB_wf } from './workflows/metaphinder_own_DB_wf'
include { vibrant_wf } from './workflows/vibrant_wf'
include { vibrant_virome_wf } from './workflows/vibrant_virome_wf'
include { virsorter_wf } from './workflows/virsorter_wf'
include { virsorter_virome_wf } from './workflows/virsorter_virome_wf'
include { virsorter2_wf } from './workflows/virsorter2_wf'
include { sourmash_wf } from './workflows/sourmash_wf'
include { prepare_results_wf } from './workflows/prepare_results_wf'
include { phage_annotation_wf } from './workflows/phage_annotation_wf'
include { checkV_wf } from './workflows/checkV_wf'
include { phage_tax_classification_wf } from './workflows/phage_tax_classification_wf'
include { setup_wf } from './workflows/setup_wf'
include { get_test_data_wf } from './workflows/get_test_data_wf'


/************************** 
* WtP Workflow
**************************/

workflow {

/************************** 
* WtP setup
**************************/

    if ( params.setup ) { setup_wf() }
    else {
    if (workflow.profile.contains('test') && !workflow.profile.contains('smalltest')) { fasta_input_ch = get_test_data_wf() }
    if (workflow.profile.contains('smalltest') ) 
        { fasta_input_ch = Channel.fromPath(workflow.projectDir + "/test-data/all_pos_phage.fa", checkIfExists: true).map { file -> tuple(file.simpleName, file) }.view() }
    }
/************************** 
* worflow flow control
**************************/
    // create 3 "input channels" for each flow
    if ( params.fasta && params.annotate && !params.identify && !params.setup) { annotation_channel =   input_validation_wf(fasta_input_ch) }
    else if (params.fasta && params.identify && !params.annotate && !params.setup ) { prediction_channel =  input_validation_wf(fasta_input_ch) }
    else if (params.fasta && !params.identify && !params.annotate && !params.setup ) { prediction_channel =  input_validation_wf(fasta_input_ch) }

/************************** 
* Prediction
**************************/
    // run annotation if identify flag or no flag at all
    if (params.fasta && params.identify && !params.annotate && !params.setup || params.fasta && !params.identify && !params.annotate && !params.setup )  { 
    // actual tools     
        results = deepvirfinder_wf( prediction_channel)
                .concat( phigaro_wf(prediction_channel))
                .concat( seeker_wf(prediction_channel))
                .concat( virfinder_wf(prediction_channel))
                .concat( virnet_wf(prediction_channel))
                .concat( pprmeta_wf(prediction_channel))
                .concat( metaphinder_wf(prediction_channel))
                .concat( metaphinder_own_DB_wf(prediction_channel))
                .concat( vibrant_wf(prediction_channel))
                .concat( vibrant_virome_wf(prediction_channel))
                .concat( virsorter_wf(prediction_channel))
                .concat( virsorter_virome_wf(prediction_channel))
                .concat( virsorter2_wf(prediction_channel))
                .concat( sourmash_wf(prediction_channel))
                .filter { it != 'deactivated' } // removes deactivated tool channels
                .groupTuple()

        prepare_results_wf(results, prediction_channel)

        // map identify output for input of annotaion tools
        annotation_channel = input_validation_wf.out.join(results)
    }
    
/************************** 
* Annotation
**************************/
    // run annotation if annotate flag or no flag at all
    if  ( params.fasta && params.annotate && !params.identify && !params.setup || params.fasta && !params.identify && !params.annotate && !params.setup ) {
    // actual tools    
        phage_annotation_wf(annotation_channel)
        checkV_wf(annotation_channel).view()
        phage_tax_classification_wf(annotation_channel)
    }


/************************** 
* Result Report
**************************/

    // TBC

}

/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    .
    ${c_yellow}Usage examples:${c_reset}
    nextflow run replikation/What_the_Phage --fasta '*/*.fasta' --cores 20 --max_cores 40 \\
        --output results -profile local,docker 

    nextflow run phage.nf --fasta '*/*.fasta' --cores 20 \\
        --output results -profile lsf,singularity \\
        --cachedir /images/singularity_images \\
        --databases /databases/WtP_databases/ 

    ${c_yellow}Input:${c_reset}
     --fasta             '*.fasta'   -> assembly file(s)
     --fastq             '*.fastq'   -> long read file(s)
    ${c_dim}  ..change above input to csv via --list ${c_reset}  
    ${c_dim}   e.g. --fasta inputs.csv --list    
        the .csv contains per line: name,/path/to/file${c_reset}  
     --setup              skips analysis and just downloads databases and containers

    ${c_yellow}Execution/Engine profiles:${c_reset}
     WtP supports profiles to run via different ${c_green}Executers${c_reset} and ${c_blue}Engines${c_reset} e.g.:
     -profile ${c_green}local${c_reset},${c_blue}docker${c_reset}

      ${c_green}Executer${c_reset} (choose one):
      slurm
      local
      lsf
      ebi
      ${c_blue}Engines${c_reset} (choose one):
      docker
      singularity
    
    For a test run (~ 1h), add "smalltest" to the profile, e.g. -profile smalltest,local,singularity 
    
    ${c_yellow}Options:${c_reset}
    --filter            min contig size [bp] to analyse [default: $params.filter]
    --cores             max cores per process for local use [default: $params.cores]
    --max_cores         max cores used on the machine for local use [default: $params.max_cores]    
    --output            name of the result folder [default: $params.output]

    ${c_yellow}Tool control:${c_reset}
    Deactivate tools individually by adding one or more of these flags
    --dv                deactivates deepvirfinder
    --mp                deactivates metaphinder
    --pp                deactivates PPRmeta
    --sm                deactivates sourmash
    --vb                deactivates vibrant
    --vf                deactivates virfinder
    --vn                deactivates virnet
    --vs                deactivates virsorter
    --ph                deactivates phigaro
    --vs2               deactivates virsorter2
    --sk                deactivates seeker

    Adjust tools individually
    --virome            deactivates virome-mode (vibrand and virsorter)
    --dv_filter         p-value cut-off [default: $params.dv_filter]
    --mp_filter         average nucleotide identity [default: $params.mp_filter]
    --vf_filter         score cut-off [default: $params.vf_filter]
    --vs2_filter        dsDNAphage score cut-off [default: $params.vs2_filter]
    --sm_filter         Similarity score [default: $params.sm_filter]
    --vn_filter         Score [default: $params.vn_filter]
    --sk_filter         score cut-off [default: $params.sk_filter]

    Workflow control:
    --identify          only phage identification, skips analysis
    --annotate          only annotation, skips phage identification

    ${c_yellow}Databases, file, container behaviour:${c_reset}
    --databases         specifiy download location of databases 
                        [default: ${params.databases}]
                        ${c_dim}WtP downloads DBs if not present at this path${c_reset}

    --workdir           defines the path where nextflow writes temporary files 
                        [default: $params.workdir]

    --cachedir          defines the path where singularity images are cached
                        [default: $params.cachedir] 

    """.stripIndent()
}

if (!params.setup) {
    workflow.onComplete { 
        log.info ( workflow.success ? "\nDone! Results are stored here --> $params.output \nThank you for using What the Phage\n \nPlease cite us: https://doi.org/10.1101/2020.07.24.219899 \
                                      \n\nPlease also cite the other tools we use in our workflow --> $params.output/literature \n" : "Oops .. something went wrong" )
    }
}
