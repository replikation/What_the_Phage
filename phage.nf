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
       if ( params.ma && params.mp && params.vf && params.vs && params.pp && params.dv && params.sm && params.vn) {
            exit 0, "You deactivated all the tools, so iam done ;) "}

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
    include './modules/databases/download_references' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/databases/phage_references_blastDB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/databases/ppr_download_dependencies' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/databases/sourmash_download_DB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/databases/virsorter_download_DB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/deepvirfinder' params(output: params.output, cpus: params.cpus)
    include './modules/fastqTofasta' params(output: params.output)
    include './modules/input_suffix_check' params(fastq: params.fastq)
    include './modules/marvel' params(output: params.output, cpus: params.cpus)
    include './modules/metaphinder' params(output: params.output, cpus: params.cpus)
    include './modules/parser/filter_PPRmeta' params(output: params.output)
    include './modules/parser/filter_deepvirfinder' params(output: params.output)
    include './modules/parser/filter_marvel' params(output: params.output)
    include './modules/parser/filter_metaphinder' params(output: params.output)
    include './modules/parser/filter_sourmash' params(output: params.output)
    include './modules/parser/filter_tool_names' params(output: params.output)
    include './modules/parser/filter_virfinder' params(output: params.output)
    include './modules/parser/filter_virsorter' params(output: params.output, cpus: params.cpus)
    include './modules/parser/parse_reads.nf' params(output: params.output)
    include './modules/r_plot.nf' params(output: params.output)
    include './modules/r_plot_reads.nf' params(output: params.output)
    include './modules/removeSmallReads' params(output: params.output)
    include './modules/samtools' params(output: params.output)
    include './modules/shuffle_reads_nts' params(output: params.output)
    include './modules/sourmash' params(output: params.output)
    include './modules/split_multi_fasta' params(output: params.output)
    include './modules/upsetr.nf' params(output: params.output)
    include './modules/virfinder' params(output: params.output, cpus: params.cpus)
    include './modules/virsorter' params(output: params.output, cpus: params.cpus)
    include './modules/virnet' params(output: params.output, cpus: params.cpus)
    include './modules/databases/virnet_download_dependencies' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
    include './modules/parser/filter_virnet' params(output: params.output)
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

workflow sourmash_database {
    get: references
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { sourmash_download_DB(references); db = sourmash_download_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.cloudDatabase}/sourmash/phages.sbt.json.tar.gz")
            if (db_preload.exists()) { db = db_preload }
            else  { sourmash_download_DB(references); db = sourmash_download_DB.out } 
        }
    emit: db
} 

workflow phage_references {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { download_references(); db = download_references.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.cloudDatabase}/references/phage_references.fa")
            if (db_preload.exists()) { db = db_preload }
            else  { download_references(); db = download_references.out } 
        }
    emit: db
} 

workflow phage_blast_DB {
    get: references
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { phage_references_blastDB(references); db = phage_references_blastDB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.cloudDatabase}/blast_phage_DB")
            if (db_preload.exists()) { db = db_preload }
            else  { phage_references_blastDB(references); db = phage_references_blastDB.out } 
        }
    emit: db
} 


workflow virnet_dependecies {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { virnet_download_dependencies(); db = virnet_download_dependencies.out }
        // cloud storage via db_preload.exists()
        // if (params.cloudProcess) {
        //     db_preload = file("${params.cloudDatabase}/pprmeta/PPR-Meta")
        //     if (db_preload.exists()) { db = db_preload }
            else  { virnet_download_dependencies(); db = virnet_download_dependencies.out } 
        // }
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

workflow read_shuffling_wf {
    get:    fastq
    main:   fastqTofasta(shuffle_reads_nts(removeSmallReads(fastq.splitFastq(by: 10000, file: true))))
    emit:   fastqTofasta.out
} 

workflow sourmash_wf {
    get:    fasta
            sourmash_database
    main:   
            if (!params.sm) { 
                        filter_sourmash(sourmash(split_multi_fasta(fasta), sourmash_database).groupTuple(remainder: true)) ; 
                        sourmash_results = filter_sourmash.out 
                        }
            else { sourmash_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   sourmash_results
} 

workflow deepvirfinder_wf {
    get:    fasta
    main:   
            if (!params.dv) { 
                        filter_deepvirfinder(deepvirfinder(fasta).groupTuple(remainder: true)) ; 
                        deepvirfinder_results = filter_deepvirfinder.out 
                        }
            else { deepvirfinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   deepvirfinder_results
} 

workflow marvel_wf {
    get:    fasta
    main:   if (!params.ma) { 
                        filter_marvel(marvel(split_multi_fasta(fasta)).groupTuple(remainder: true)) ; 
                        marvel_results = filter_marvel.out 
                        }
            else { marvel_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   marvel_results
}

workflow metaphinder_wf {
    get:    fasta
    main:   if (!params.mp) { 
                        filter_metaphinder(metaphinder(fasta).groupTuple(remainder: true)) ; 
                        metaphinder_results = filter_metaphinder.out 
                        }
            else { metaphinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_results
} 

workflow metaphinder_own_DB_wf {
    get:    fasta
            blast_db
    main:   if (!params.mp) { 
                        filter_metaphinder_own_DB(metaphinder_own_DB(fasta, blast_db).groupTuple(remainder: true)) ; 
                        metaphinder_results = filter_metaphinder_own_DB.out 
                        }
            else { metaphinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_results
} 

workflow virfinder_wf {
    get:    fasta
    main:   if (!params.vf) { 
                        filter_virfinder(virfinder(fasta).groupTuple(remainder: true)) ; 
                        virfinder_results = filter_virfinder.out 
                        }
            else { virfinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virfinder_results
} 

workflow virsorter_wf {
    get:    fasta
            virsorter_DB
    main:   if (!params.vs) { 
                        filter_virsorter(virsorter(fasta, virsorter_DB).groupTuple(remainder: true)) ; 
                         virsorter_results = filter_virsorter.out 
                        }
            else { virsorter_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virsorter_results
} 

workflow pprmeta_wf {
    get:    fasta
            ppr_deps
    main:   if (!params.pp) { 
                        filter_PPRmeta(pprmeta(fasta, ppr_deps).groupTuple(remainder: true)) ; 
                         pprmeta_results = filter_PPRmeta.out 
                        }
            else { pprmeta_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   pprmeta_results
} 

workflow virnet_wf {
    get:    fasta
            virnet_dependecies
    main:   if (!params.vn) { 
                        filter_virnet(virnet(fasta, virnet_dependecies).groupTuple(remainder: true)) ; 
                        virnet_results = filter_virnet.out 
                        }
            else { virnet_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virnet_results
} 

/************* 
* MAIN WORKFLOWS
*************/

workflow {
    if (params.fasta && !params.fastq) {
    // input filter
        fasta_validation_wf(fasta_input_ch)

    // reference phages into DBs creations
        phage_references() | ( sourmash_database & phage_blast_DB )

    // gather results
        results =   virsorter_wf(fasta_validation_wf.out, virsorter_database())
                    .concat(marvel_wf(fasta_validation_wf.out))
                    .concat(sourmash_wf(fasta_validation_wf.out, sourmash_database.out))
                    .concat(metaphinder_wf(fasta_validation_wf.out))
                    .concat(metaphinder_own_DB_wf(fasta_validation_wf.out, phage_blast_DB.out))
                    .concat(deepvirfinder_wf(fasta_validation_wf.out))
                    .concat(virfinder_wf(fasta_validation_wf.out))
                    .concat(pprmeta_wf(fasta_validation_wf.out, ppr_dependecies()))
                    .concat(virnet_wf(fasta_validation_wf.out, virnet_dependecies()))
                    .filter { it != 'deactivated' } // removes deactivated tool channels
                    .groupTuple()
                    
        filter_tool_names(results) 
                           
    //plotting results
        r_plot(filter_tool_names.out)
        upsetr_plot(filter_tool_names.out)
    //samtools 
       samtools(fasta_validation_wf.out.join((filter_tool_names.out)))    
    }
    
    if (!params.fasta && params.fastq) {
    // input filter
        read_validation_wf(fastq_input_ch)

    // reference phages into DBs creations
        phage_references() | ( phage_blast_DB )
    
    // gather results
        results =   metaphinder_wf(read_validation_wf.out)
                    .concat(metaphinder_own_DB_wf(read_validation_wf.out, phage_blast_DB.out))
                    .concat(virfinder_wf(read_validation_wf.out))
                    .concat(pprmeta_wf(read_validation_wf.out, ppr_dependecies()))
                    .filter { it != 'deactivated' } // removes deactivated tool channels
                    .groupTuple()
        
        filter_tool_names(results)
        

    //plotting results
        r_plot_reads(parse_reads(results))
        upsetr_plot(filter_tool_names.out)
    
    //samtools 
       samtools(read_validation_wf.out.join(results)) 
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

    ${c_yellow}Tool control (BETA feature - might break the plots):${c_reset}
    All tools are activated by default, deactivate them by adding one or more flags
    --dv                deactivates deepvirfinder
    --ma                deactivates marvel
    --mp                deactivates metaphinder
    --vf                deactivates virfinder
    --vs                deactivates virsorter
    --pp                deactivates PPRmeta

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