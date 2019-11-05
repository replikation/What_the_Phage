#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
* Nextflow -- Analysis Pipeline
* Author: christian.jena@gmail.com
*/
if (params.help) { exit 0, helpMSG() }

/*
println "  __      _______________________ "
println " /  \    /  \__    ___/\______   \"
println " \   \/\/   / |    |    |     ___/"
println "  \        /  |    |    |    |    "
println "   \__/\  /   |____|    |____|    "
println "        \/                        "
*/


println " "
println "\u001B[32mProfile: $workflow.profile\033[0m"
println " "
println "\033[2mCurrent User: $workflow.userName"
println "Nextflow-version: $nextflow.version"
println "Starting time: $nextflow.timestamp"
println "Workdir location:"
println "  $workflow.workDir\u001B[0m"
println " "
if (workflow.profile == 'standard') {
println "\033[2mCPUs to use: $params.cores"
println "Output dir name: $params.output\u001B[0m"
println " "}

/************* 
* INPUT HANDLING
*************/
        if (params.fasta == '' ) {
            exit 1, "input missing, use [--fasta]"}
    // fasta input or via csv file
        if (params.fasta && params.list) { fasta_input_ch = Channel
                .fromPath( params.fasta, checkIfExists: true )
                .splitCsv()
                .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
                 }
        else if (params.fasta) { fasta_input_ch = Channel
                .fromPath( params.fasta, checkIfExists: true)
                .map { file -> tuple(file.baseName, file) }
                 }

/************* 
* MODULES
*************/

    include './modules/PPRmeta' params(output: params.output, cpus: params.cpus)
    include './modules/deepvirfinder' params(output: params.output, cpus: params.cpus)
    include './modules/filter_PPRmeta' params(output: params.output)
    include './modules/filter_deepvirfinder' params(output: params.output)
    include './modules/filter_marvel' params(output: params.output)
    include './modules/filter_metaphinder' params(output: params.output)
    include './modules/filter_virfinder' params(output: params.output)
    include './modules/filter_virsorter' params(output: params.output, cpus: params.cpus)
    include './modules/marvel' params(output: params.output, cpus: params.cpus)
    include './modules/metaphinder' params(output: params.output, cpus: params.cpus)
    include './modules/ppr_download_dependencies' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/r_plot.nf' params(output: params.output, cpus: params.cpus)
    include './modules/virfinder' params(output: params.output, cpus: params.cpus)
    include './modules/virsorter' params(output: params.output, cpus: params.cpus)
    include './modules/virsorter_download_DB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/input_suffix_check'


/************* 
* DATABASES
*************/
workflow ppr_dependecies {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { ppr_download_dependencies(); db = ppr_download_dependencies.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.cloudDatabase}/pprmeta/PPR-Meta")
            if (db_preload.exists()) { db = db_preload }
            else  { ppr_download_dependencies(); db = ppr_download_dependencies.out } 
        }
    emit: db
}        

workflow virsorter_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { virsorter_download_DB(); db = virsorter_download_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.cloudDatabase}/virsorter/virsorter-data")
            if (db_preload.exists()) { db = db_preload }
            else  { virsorter_download_DB(); db = virsorter_download_DB.out } 
        }
    emit: db
} 

/************* 
* SUB WORKFLOWS
*************/

workflow deepvirfinder_wf {
    get:    fasta
    main:   filter_deepvirfinder(deepvirfinder(input_suffix_check(fasta)))
    emit:   filter_deepvirfinder.out
} 

workflow marvel_wf {
    get:    fasta
    main:   filter_marvel(marvel(input_suffix_check(fasta).splitFasta(by: 1, file: true).groupTuple()))
    emit:   filter_marvel.out
} 

workflow metaphinder_wf {
    get:    fasta
    main:   filter_metaphinder(metaphinder(input_suffix_check(fasta)))
    emit:   filter_metaphinder.out
} 

workflow virfinder_wf {
    get:    fasta
    main:   filter_virfinder(virfinder(input_suffix_check(fasta)))
    emit:   filter_virfinder.out
} 

workflow virsorter_wf {
    get:    fasta
            virsorter_DB
    main:   filter_virsorter(virsorter(input_suffix_check(fasta), virsorter_DB))
    emit:   filter_virsorter.out
} 

workflow pprmeta_wf {
    get:    fasta
            ppr_deps
    main:   filter_PPRmeta(pprmeta(input_suffix_check(fasta), ppr_deps))
    emit:   filter_PPRmeta.out
} 

/************* 
* MAIN WORKFLOWS
*************/

workflow {
        r_plot (    virsorter_wf(fasta_input_ch, virsorter_database())
                    .join(marvel_wf(fasta_input_ch), by:0)
                    .join(metaphinder_wf(fasta_input_ch), by:0)
                    .join(deepvirfinder_wf(fasta_input_ch), by:0)
                    .join(virfinder_wf(fasta_input_ch), by:0)
                    .join(pprmeta_wf(fasta_input_ch, ppr_dependecies()), by:0)
                )
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
    ____________________________________________________________________________________________
    
    What the Phage (WTP)
    
    ${c_yellow}Usage example:${c_reset}
    nextflow run phage.nf --fasta '*/*.fasta' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --fasta ${c_reset}            '*.fasta'   -> assembly file(s) - uses filename
    ${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}            

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --output            name of the result folder [default: $params.output]

    ${c_yellow}Database behaviour:${c_reset}
    This workflow will automatically download files to ./nextflow-autodownload-databases
    It will skip this download if the files are present in ./nextflow-autodownload-databases
    
    ${c_yellow}HPC or cloud computing:${c_reset}
    For execution of the workflow in the cloud or on a HPC (such as provided with LSF) 
    you might want to adjust the following parameters.
    --databases         defines the path where databases are stored [default: $params.cloudDatabase]
    --workdir           defines the path where nextflow writes tmp files [default: $params.workdir]
    --cachedir          defines the path where images (singularity) are cached [default: $params.cachedir] 

    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard, lsf [default: standard] ${c_reset}
    """.stripIndent()
}