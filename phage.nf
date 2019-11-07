#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
* Nextflow -- What the Phage
* Author: christian.jena@gmail.com
*/


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
        if ( !params.fasta && !params.fastq ) {
            exit 1, "input missing, use [--fasta] or [--fastq]"}
        if ( params.fasta && params.fastq ) {
            exit 1, "please use either [--fasta] or [--fastq] as input"}
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
    // fastq input or via csv file
        if (params.fastq && params.list) { fastq_input_ch = Channel
                .fromPath( params.fastq, checkIfExists: true )
                .splitCsv()
                .map { row -> ["${row[0]}", file("${row[1]}", checkIfExists: true)] }
                 }
        else if (params.fastq) { fastq_input_ch = Channel
                .fromPath( params.fastq, checkIfExists: true)
                .map { file -> tuple(file.baseName, file) }
                 }

/************* 
* MODULES
*************/

    include './modules/PPRmeta' params(output: params.output, cpus: params.cpus)
    include './modules/deepvirfinder' params(output: params.output, cpus: params.cpus)
    include './modules/fastqTofasta' params(output: params.output)
    include './modules/filter_PPRmeta' params(output: params.output)
    include './modules/filter_deepvirfinder' params(output: params.output)
    include './modules/filter_marvel' params(output: params.output)
    include './modules/filter_metaphinder' params(output: params.output)
    include './modules/filter_virfinder' params(output: params.output)
    include './modules/filter_virsorter' params(output: params.output, cpus: params.cpus)
    include './modules/input_suffix_check' params(fastq: params.fastq)
    include './modules/marvel' params(output: params.output, cpus: params.cpus)
    include './modules/metaphinder' params(output: params.output, cpus: params.cpus)
    include './modules/parse_reads.nf' params(output: params.output)
    include './modules/ppr_download_dependencies' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/r_plot.nf' params(output: params.output)
    include './modules/r_plot_reads.nf' params(output: params.output)
    include './modules/removeSmallReads' params(output: params.output)
    include './modules/virfinder' params(output: params.output, cpus: params.cpus)
    include './modules/virsorter' params(output: params.output, cpus: params.cpus)
    include './modules/virsorter_download_DB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)


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
workflow fasta_validation_wf {
    get:    fasta
    main:   input_suffix_check(fasta)
    emit:   input_suffix_check.out
}

workflow read_validation_wf {
    get:    fastq
    main:   fastqTofasta(removeSmallReads(fastq.splitFastq(by: 10000, file: true)))
    emit:   fastqTofasta.out
} 


workflow deepvirfinder_wf {
    get:    fasta
    main:   filter_deepvirfinder(deepvirfinder(fasta).groupTuple(remainder: true))
    emit:   filter_deepvirfinder.out
} 

workflow marvel_wf {
    get:    fasta
    main:   filter_marvel(marvel(fasta.splitFasta(by: 1, file: true).groupTuple()).groupTuple(remainder: true))
    emit:   filter_marvel.out
} 

workflow metaphinder_wf {
    get:    fasta
    main:   filter_metaphinder(metaphinder(fasta).groupTuple(remainder: true))
    emit:   filter_metaphinder.out
} 

workflow virfinder_wf {
    get:    fasta
    main:   filter_virfinder(virfinder(fasta).groupTuple(remainder: true))
    emit:   filter_virfinder.out
} 

workflow virsorter_wf {
    get:    fasta
            virsorter_DB
    main:   filter_virsorter(virsorter(fasta, virsorter_DB).groupTuple(remainder: true))
    emit:   filter_virsorter.out
} 

workflow pprmeta_wf {
    get:    fasta
            ppr_deps
    main:   filter_PPRmeta(pprmeta(fasta, ppr_deps).groupTuple(remainder: true))
    emit:   filter_PPRmeta.out
} 

/************* 
* MAIN WORKFLOWS
*************/

workflow {
    if (params.fasta && !params.fastq) {
        
        fasta_validation_wf(fasta_input_ch)

        r_plot(     virsorter_wf(fasta_validation_wf.out, virsorter_database())
                    .concat(marvel_wf(fasta_validation_wf.out))
                    .concat(metaphinder_wf(fasta_validation_wf.out))
                    .concat(deepvirfinder_wf(fasta_validation_wf.out))
                    .concat(virfinder_wf(fasta_validation_wf.out))
                    .concat(pprmeta_wf(fasta_validation_wf.out, ppr_dependecies()))
                    .groupTuple()
        )
    }
    
    if (!params.fasta && params.fastq) {
 
        read_validation_wf(fastq_input_ch)

        r_plot_reads(parse_reads(    metaphinder_wf(read_validation_wf.out)
                                    .concat(virfinder_wf(read_validation_wf.out))
                                    .concat(pprmeta_wf(read_validation_wf.out, ppr_dependecies()))
                                    .groupTuple()
        )   )
    }

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
    ${c_yellow}Usage example:${c_reset}
    nextflow run phage.nf --fasta '*/*.fasta' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --fasta ${c_reset}            '*.fasta'   -> assembly file(s)
    ${c_green} --fastq ${c_reset}            '*.fastq'   -> long read file(s)
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