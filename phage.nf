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
                .map { row -> ["${row[0]}", file("${row[1]}")] }
                .view() }
        else if (params.fasta) { fasta_input_ch = Channel
                .fromPath( params.fasta, checkIfExists: true)
                .map { file -> tuple(file.baseName, file) }
                .view() }
    // check suffixes and correct/unpacuk them
        include 'modules/input_suffix_check'
        input_suffix_check(fasta_input_ch)

/************* 
* DATABASES - autoload
*************/
    // get PPR dependencies
        include 'modules/ppr_download_dependencies'
        ppr_download_dependencies() 
        deps_PPRmeta = ppr_download_dependencies.out

    // get Virsorter Database
        include 'modules/virsorter_download_DB'
        virsorter_download_DB() 
        database_virsorter = virsorter_download_DB.out

/*************  
* Deepvirfinder
*************/
    if (params.fasta) { 
            include 'modules/deepvirfinder' params(output: params.output, cpus: params.cpus)
            include 'modules/filter_deepvirfinder' params(output: params.output)
        filter_deepvirfinder(deepvirfinder(input_suffix_check.out)) }
/*************  
* Marvel
*************/
    if (params.fasta) { 
            include 'modules/marvel' params(output: params.output, cpus: params.cpus)
            include 'modules/filter_marvel' params(output: params.output)
        filter_marvel(marvel(input_suffix_check.out)) }
/*************  
* Metaphinder
*************/
    if (params.fasta) { 
            include 'modules/metaphinder' params(output: params.output, cpus: params.cpus)
            include 'modules/filter_metaphinder' params(output: params.output)
        filter_metaphinder(metaphinder(input_suffix_check.out)) }
/*************  
* Virfinder
*************/
    if (params.fasta) { 
            include 'modules/virfinder' params(output: params.output, cpus: params.cpus)
            include 'modules/filter_virfinder' params(output: params.output)
        filter_virfinder(virfinder(input_suffix_check.out)) }
/*************  
* Virsorter
*************/
if (params.fasta) { 
        include 'modules/virsorter' params(output: params.output, cpus: params.cpus)
        include 'modules/filter_virsorter' params(output: params.output, cpus: params.cpus)
    filter_virsorter(virsorter(input_suffix_check.out, database_virsorter)) }
/*************  
* PPRmeta
*************/
if (params.fasta) { 
        include 'modules/PPRmeta' params(output: params.output, cpus: params.cpus)
        include 'modules/filter_PPRmeta' params(output: params.output)
    filter_PPRmeta(pprmeta(input_suffix_check.out, deps_PPRmeta)) }


/***************************************      
* JOIN ALL TOOL RESULTS
***************************************/

rchannel = filter_metaphinder.out.join(filter_deepvirfinder.out.join(filter_marvel.out.join(filter_virfinder.out.join(filter_virsorter.out.join(filter_PPRmeta.out)))))


/*************  
* R plot
*************/

if (params.fasta) { include 'modules/r_plot.nf' params(output: params.output, cpus: params.cpus)
    r_plot(rchannel) }

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

    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard [default: standard] ${c_reset}
    """.stripIndent()
}