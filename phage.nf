#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
* Nextflow -- Analysis Pipeline
* Author: christian.jena@gmail.com
*/

if (params.help) { exit 0, helpMSG() }
if (params.fasta == '' &&  params.fastq == '' &&  params.dir == '') {
    exit 1, "input missing, use [--fasta] [--fastq] or [--dir]"}

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

if (params.fastq && params.list) { fastq_input_ch = Channel
        .fromPath( params.fastq, checkIfExists: true )
        .splitCsv()
        .map { row -> ["${row[0]}", file("${row[1]}")] }
        .view() }
else if (params.fastq) { fastq_input_ch = Channel
        .fromPath( params.fastq, checkIfExists: true)
        .map { file -> tuple(file.baseName, file) }
        .view() }

if (params.dir && params.list) { dir_input_ch = Channel
        .fromPath( params.dir, checkIfExists: true, type: 'dir' )
        .splitCsv()
        .map { row -> ["${row[0]}", file("${row[1]}")] }
        .view() }
if (params.dir) { dir_input_ch = Channel
        .fromPath( params.dir, checkIfExists: true, type: 'dir')
        .map { file -> tuple(file.name, file) }
        .view() }


/************* 
* DATABASES - autoload
*************/
/*
if (params.sourmeta || params.sourclass) {
    sour_db_preload = file(params.sour_db_present)
    if (params.sour_db) { database_sourmash = file(params.sour_db) }
    else if (sour_db_preload.exists()) { database_sourmash = sour_db_preload }
    else {  include 'modules/sourmashgetdatabase'
            sourmash_download_db() 
            database_sourmash = sourmash_download_db.out } }
*/
/*************  
* Deepvirfinder
*************/
if (params.fasta) { include 'modules/deepvirfinder' params(output: params.output, cpus: params.cpus)
    deepvirfinder(fasta_input_ch) }

/*************  
* Marvel
*************/
// Its not finding any thing in the fastas - its looking more for bins...
// maybe split the contigs of a fasta into "bins" and then start the prediction?
// otherwise its working

if (params.fasta) { include 'modules/marvel' params(output: params.output, cpus: params.cpus)
    marvel(fasta_input_ch) }

/*************  
* Metaphinder
*************/
if (params.fasta) { include 'modules/metaphinder' params(output: params.output, cpus: params.cpus)
    metaphinder(fasta_input_ch) }

/*************  
* Virfinder
*************/
if (params.fasta) { include 'modules/virfinder' params(output: params.output, cpus: params.cpus)
    virfinder(fasta_input_ch) }



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
    
    phageME
    
    ${c_yellow}Usage example:${c_reset}
    nextflow run phage.nf --fasta '*/*.fasta' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --fasta ${c_reset}            '*.fasta'   -> assembly file(s) - uses filename
    ${c_green} --fastq ${c_reset}            '*.fastq'   -> read file(s) in fastq, one sample per file - uses filename
    ${c_green} --dir  ${c_reset}             'foobar*/'  -> a folder(s) as input - uses dirname
    ${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}            

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --output            name of the result folder [default: $params.output]


    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard [default: standard] ${c_reset}
    """.stripIndent()
}