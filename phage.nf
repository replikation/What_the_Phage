#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
* Nextflow -- What the Phage
* Author: christian.jena@gmail.com
*/

if ( !nextflow.version.matches('20.+') ) {
    println "This workflow requires Nextflow version 20.X or greater -- You are running version $nextflow.version"
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
println " "
println "\033[2mCPUs to use: $params.cores\033[0m"
println " "

/************* 
* ERROR HANDLING
*************/
// profiles
if ( workflow.profile == 'standard' ) { exit 1, "NO VALID EXECUTION PROFILE SELECTED, use e.g. [-profile local,docker]" }

if (
    workflow.profile.contains('singularity') ||
    workflow.profile.contains('docker')
    ) { "engine selected" }
else { exit 1, "No engine selected:  -profile EXECUTER,ENGINE" }

if (
    workflow.profile.contains('local') ||
    workflow.profile.contains('ebi') ||
    workflow.profile.contains('lsf') ||
    workflow.profile.contains('git_action')
    ) { "executer selected" }
else { exit 1, "No executer selected:  -profile EXECUTER,ENGINE" }

// params tests
if (!params.setup) {
    if ( !params.fasta && !params.fastq ) {
        exit 1, "input missing, use [--fasta] or [--fastq]"}
    if ( params.fasta && params.fastq ) {
        exit 1, "please use either [--fasta] or [--fastq] as input"}
    if ( params.ma && params.mp && params.vf && params.vs && params.pp && params.dv && params.sm && params.vn && params.vb ) {
        exit 0, "What the... you deactivated all the tools"}
}


/************* 
* INPUT HANDLING
*************/

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

    include chromomap from './modules/chromomap'
    include chromomap_parser from './modules/parser/chromomap_parser'
    include deepvirfinder from './modules/tools/deepvirfinder'
    include deepvirfinder_collect_data from './modules/raw_data_collection/deepvirfinder_collect_data'
    include download_references from './modules/databases/download_references'
    include fastqTofasta from './modules/fastqTofasta'
    include filter_PPRmeta from './modules/parser/filter_PPRmeta'
    include filter_deepvirfinder from './modules/parser/filter_deepvirfinder'
    include filter_marvel from './modules/parser/filter_marvel'
    include filter_metaphinder from './modules/parser/filter_metaphinder'
    include filter_metaphinder_own_DB from './modules/parser/filter_metaphinder'
    include filter_sourmash from './modules/parser/filter_sourmash'
    include filter_tool_names from './modules/parser/filter_tool_names'
    include filter_vibrant from './modules/parser/filter_vibrant'
    include filter_virfinder from './modules/parser/filter_virfinder'
    include filter_virnet from './modules/parser/filter_virnet'
    include filter_virsorter from './modules/parser/filter_virsorter' 
    include hmmscan from './modules/hmmscan'
    include input_suffix_check from './modules/input_suffix_check'
    include marvel from './modules/tools/marvel'
    include marvel_collect_data from './modules/raw_data_collection/marvel_collect_data'
    include metaphinder from './modules/tools/metaphinder'
    include metaphinder_collect_data from './modules/raw_data_collection/metaphinder_collect_data'
    include metaphinder_collect_data_ownDB from './modules/raw_data_collection/metaphinder_collect_data'
    include metaphinder_own_DB from './modules/tools/metaphinder'
    include normalize_contig_size from './modules/normalize_contig_size'
    include parse_reads from './modules/parser/parse_reads.nf'
    include phage_references_blastDB from './modules/databases/phage_references_blastDB'
    include ppr_download_dependencies from './modules/databases/ppr_download_dependencies'
    include pprmeta from './modules/tools/pprmeta'
    include pprmeta_collect_data from './modules/raw_data_collection/pprmeta_collect_data'
    include prodigal from './modules/prodigal'
    include pvog_DB from './modules/databases/download_pvog_DB'
    include r_plot from './modules/r_plot.nf' 
    include r_plot_reads from './modules/r_plot_reads.nf'
    include removeSmallReads from './modules/removeSmallReads'
    include rvdb_DB from './modules/databases/download_rvdb_DB'
    include samtools from './modules/samtools'
    include seqkit from './modules/seqkit'
    include setup_container from './modules/setup_container'
    include shuffle_reads_nts from './modules/shuffle_reads_nts'
    include sourmash from './modules/tools/sourmash'
    include sourmash_collect_data from './modules/raw_data_collection/sourmash_collect_data'
    include sourmash_download_DB from './modules/databases/sourmash_download_DB'
    include split_multi_fasta from './modules/split_multi_fasta'
    include upsetr_plot from './modules/upsetr.nf'
    include vibrant from './modules/tools/vibrant'
    include vibrant_collect_data from './modules/raw_data_collection/vibrant_collect_data'
    include vibrant_download_DB from './modules/databases/vibrant_download_DB'
    include virfinder from './modules/tools/virfinder'
    include virfinder_collect_data from './modules/raw_data_collection/virfinder_collect_data'
    include virnet from './modules/tools/virnet'
    include virnet_collect_data from './modules/raw_data_collection/virnet_collect_data'
    include virnet_download_dependencies from './modules/databases/virnet_download_dependencies'
    include virsorter from './modules/tools/virsorter'
    include virsorter_collect_data from './modules/raw_data_collection/virsorter_collect_data'
    include virsorter_download_DB from './modules/databases/virsorter_download_DB'
    include vog_DB from './modules/databases/download_vog_DB'

/************* 
* DATABASES for Phage Identification
*************/
workflow ppr_dependecies {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { ppr_download_dependencies(); db = ppr_download_dependencies.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/pprmeta/PPR-Meta")
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
            db_preload = file("${params.databases}/virsorter/virsorter-data")
            if (db_preload.exists()) { db = db_preload }
            else  { virsorter_download_DB(); db = virsorter_download_DB.out } 
        }
    emit: db
}

workflow sourmash_database {
    take: references
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { sourmash_download_DB(references); db = sourmash_download_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/sourmash/phages.sbt.json.tar.gz")
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
            db_preload = file("${params.databases}/references/phage_references.fa")
            if (db_preload.exists()) { db = db_preload }
            else  { download_references(); db = download_references.out } 
        }
    emit: db
} 

workflow phage_blast_DB {
    take: references
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { phage_references_blastDB(references); db = phage_references_blastDB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/blast_phage_DB")
            if (db_preload.exists()) { db = db_preload }
            else  { phage_references_blastDB(references); db = phage_references_blastDB.out } 
        }
    emit: db
} 

workflow vibrant_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { vibrant_download_DB(); db = vibrant_download_DB.out }
         //cloud storage via db_preload.exists()
         if (params.cloudProcess) {
             db_preload = file("${params.databases}/Vibrant/database.tar.gz")
             if (db_preload.exists()) { db = db_preload }
             else  { vibrant_download_DB(); db = vibrant_download_DB.out } 
        }
    emit: db
}        

workflow virnet_dependecies {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { virnet_download_dependencies(); db = virnet_download_dependencies.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/virnet/virnet")
            if (db_preload.exists()) { db = db_preload }
            else  { virnet_download_dependencies(); db = virnet_download_dependencies.out } 
        }
    emit: db
}       

/************* 
* DATABASES for Phage annotation
*************/

workflow pvog_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { pvog_DB(); db = pvog_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/pvogs/")
            if (db_preload.exists()) { db = db_preload }
            else  { pvog_DB(); db = pvog_DB.out } 
        }
    emit: db
}

workflow rvdb_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { rvdb_DB(); db = rvdb_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/pvogs/")
            if (db_preload.exists()) { db = db_preload }
            else  { rvdb_DB(); db = rvdb_DB.out } 
        }
    emit: db
}

workflow vog_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { vog_DB(); db = vog_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/pvogs/")
            if (db_preload.exists()) { db = db_preload }
            else  { vog_DB(); db = vog_DB.out } 
        }
    emit: db
}



/************* 
* SUB WORKFLOWS
*************/
workflow fasta_validation_wf {
    take:   fasta
    main:   seqkit(input_suffix_check(fasta))
    emit:   seqkit.out
}

workflow read_validation_wf {
    take:   fastq
    main:   fastqTofasta(removeSmallReads(fastq.splitFastq(by: 1000, file: true)))
    emit:   fastqTofasta.out
}

workflow read_shuffling_wf {
    take:   fastq
    main:   fastqTofasta(shuffle_reads_nts(removeSmallReads(fastq.splitFastq(by: 10000, file: true))))
    emit:   fastqTofasta.out
} 

workflow sourmash_wf {
    take:   fasta
            sourmash_database
    main:   
            if (!params.sm) { 
                        filter_sourmash(sourmash(split_multi_fasta(fasta), sourmash_database).groupTuple(remainder: true))
                        // raw data collector
                        sourmash_collect_data(sourmash.out.groupTuple(remainder: true))
                        // result channel
                        sourmash_results = filter_sourmash.out
                        }
            else { sourmash_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

    emit:   sourmash_results
} 

workflow deepvirfinder_wf {
    take:   fasta
    main:   
            if (!params.dv) { 
                        filter_deepvirfinder(deepvirfinder(fasta).groupTuple(remainder: true))
                        // raw data collector
                        deepvirfinder_collect_data(deepvirfinder.out.groupTuple(remainder: true))
                        // result channel
                        deepvirfinder_results = filter_deepvirfinder.out
                        }
            else { deepvirfinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   deepvirfinder_results 
} 

workflow marvel_wf {
    take:   fasta
    main:   if (!params.ma) { 
                        // filtering
                        filter_marvel(marvel(split_multi_fasta(fasta)).groupTuple(remainder: true))
                        // raw data collector
                        marvel_collect_data(marvel.out.groupTuple(remainder: true))
                        // result channel
                        marvel_results = filter_marvel.out 
                        }
            else { marvel_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   marvel_results 
}

workflow metaphinder_wf {
    take:   fasta
    main:   if (!params.mp) { 
                        metaphinder(fasta)
                        // filtering
                        filter_metaphinder(metaphinder.out[0].groupTuple(remainder: true))
                        // raw data collector
                        metaphinder_collect_data(metaphinder.out[1].groupTuple(remainder: true))
                        // result channel
                        metaphinder_results = filter_metaphinder.out
                        }
            else { metaphinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_results
} 

workflow metaphinder_own_DB_wf {
    take:   fasta
            blast_db
    main:   if (!params.mp) {
                        metaphinder_own_DB(fasta, blast_db)
                        // filtering
                        filter_metaphinder_own_DB(metaphinder_own_DB.out[0].groupTuple(remainder: true))
                        // raw data collector
                        metaphinder_collect_data_ownDB(metaphinder_own_DB.out[1].groupTuple(remainder: true))
                        // result channel
                        metaphinder_results = filter_metaphinder_own_DB.out
                        }
            else { metaphinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_results 
} 

workflow virfinder_wf {
    take:   fasta
    main:   if (!params.vf) { 
                        filter_virfinder(virfinder(fasta).groupTuple(remainder: true))
                        // raw data collector
                        virfinder_collect_data(virfinder.out.groupTuple(remainder: true))
                        // result channel
                        virfinder_results = filter_virfinder.out
                        }
            else { virfinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virfinder_results
} 

workflow virsorter_wf {
    take:   fasta
            virsorter_DB
    main:   if (!params.vs) {
                        virsorter(fasta, virsorter_DB)
                        // filtering
                        filter_virsorter(virsorter.out[0].groupTuple(remainder: true))
                        // raw data collector
                        virsorter_collect_data(virsorter.out[1].groupTuple(remainder: true))
                        // result channel
                        virsorter_results = filter_virsorter.out
                        }
            else { virsorter_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virsorter_results
} 

workflow pprmeta_wf {
    take:   fasta
            ppr_deps
    main:   if (!params.pp) { 
                        filter_PPRmeta(pprmeta(fasta, ppr_deps).groupTuple(remainder: true))
                        // raw data collector
                        pprmeta_collect_data(pprmeta.out.groupTuple(remainder: true))
                        // result channel
                        pprmeta_results = filter_PPRmeta.out
                        }
            else { pprmeta_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   pprmeta_results 
} 

workflow vibrant_wf {
    take:   fasta
            vibrant_download_DB
    main:    if (!params.vb) {
                        vibrant(fasta, vibrant_download_DB)
                        // filtering
                        filter_vibrant(vibrant.out[0].groupTuple(remainder: true))
                        // raw data collector
                        vibrant_collect_data(vibrant.out[1].groupTuple(remainder: true))
                        // result channel
                        vibrant_results = filter_vibrant.out
                        }
            else { vibrant_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   vibrant_results
}

workflow virnet_wf {
    take:   fasta
            virnet_dependecies
    main:   if (!params.vn) { 
                        filter_virnet(virnet(normalize_contig_size(fasta), virnet_dependecies).groupTuple(remainder: true))
                        // raw data collector
                        virnet_collect_data(virnet.out.groupTuple(remainder: true))
                        // result channel
                        virnet_results = filter_virnet.out
                        }
            else { virnet_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virnet_results
} 

workflow phage_annotation_wf {
    take :  fasta 
            pvog_DB
            vog_DB
            rvdb_DB

    main :  if (!params.anno) {
                //prodigal 
                modified_input = fasta
                                .map { it -> [it[0], it[2]] }
                prodigal(modified_input)

                modified_pvog_DB_input_for_hmmscan = pvog_DB
                                                    .map { it -> [it[0]] }

                //hmmscan
                hmmscan(prodigal.out, modified_pvog_DB_input_for_hmmscan)


                modified_hmmscan_input_for_chromomap_parser = hmmscan.out
                                                    .map { it -> [it[0], it[1]] }
                                                    
                // map only VOGTable with annotation for input of chromomap
                    // file(vogtable)
                modified_pvog_DB_input_for_chromomapparser = pvog_DB
                                                    .map { it -> [it[1]] }
                                                    
                //chromomap channel change from, to:
                    //chromomap_parser: val(name), file(positive_contigs_list), file(hmmscan_results), file(prodigal_out), path(vogtable)
                    //chromomap: val(name), path(chromosomefile), path(annotationfile)
                chromomap(
                    chromomap_parser(
                        modified_input.join(modified_hmmscan_input_for_chromomap_parser).join(prodigal.out), modified_pvog_DB_input_for_chromomapparser))
                }
            else { phage_annotation_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
}

workflow setup_wf {
    take:   
    main:       
        // docker
        if (workflow.profile.contains('docker')) {
            config_ch = Channel.fromPath( workflow.projectDir + "/configs/container.config" , checkIfExists: true)
            setup_container(config_ch)
        }
        // singularity
        if (workflow.profile.contains('singularity')) {
            config_ch2 = Channel.fromPath( workflow.projectDir + "/configs/container.config" , checkIfExists: true)
            setup_container(config_ch2)
        }

        // databases
        if (params.setup) {
            phage_references() 
            ref_phages_DB = phage_blast_DB (phage_references.out)
            ppr_deps = ppr_dependecies()
            sourmash_DB = sourmash_database (phage_references.out)
            vibrant_DB = vibrant_download_DB()
            virnet_deps = virnet_dependecies()
            virsorter_DB = virsorter_database()
        }
} 

/************* 
* MAIN WORKFLOWS
*************/

workflow {

    if (params.setup) { setup_wf() }

    if (!params.setup && params.fasta && !params.fastq) {
    // input filter
        fasta_validation_wf(fasta_input_ch)

    // reference phages, DBs and dependencies, deactivation based on input flags
        phage_references() 

        if (params.mp) { ref_phages_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { ref_phages_DB = phage_blast_DB (phage_references.out) }
        if (params.pp) { ppr_deps = Channel.from( [ 'deactivated', 'deactivated'] ) } else { ppr_deps = ppr_dependecies() }
        if (params.sm) { sourmash_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { sourmash_DB = sourmash_database (phage_references.out) }
        if (params.vb) { vibrant_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { vibrant_DB = vibrant_download_DB() }
        if (params.vn) { virnet_deps = Channel.from( [ 'deactivated', 'deactivated'] ) } else { virnet_deps = virnet_dependecies() }
        if (params.vs) { virsorter_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { virsorter_DB = virsorter_database() }
  
    // phage annotation DBs deactivation based on input flags
        if (params.anno) { pvog_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { pvog_DB = pvog_database() }
        if (params.anno) { vog_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { vog_DB = vog_database() }
        if (params.anno) { rvdb_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { rvdb_DB = rvdb_database() }

    // gather results
        results =   virsorter_wf(fasta_validation_wf.out, virsorter_DB)
                    .concat(marvel_wf(fasta_validation_wf.out))      
                    .concat(sourmash_wf(fasta_validation_wf.out, sourmash_DB))
                    .concat(metaphinder_wf(fasta_validation_wf.out))
                    .concat(metaphinder_own_DB_wf(fasta_validation_wf.out, ref_phages_DB))
                    .concat(deepvirfinder_wf(fasta_validation_wf.out))
                    .concat(virfinder_wf(fasta_validation_wf.out))
                    .concat(pprmeta_wf(fasta_validation_wf.out, ppr_deps))
                    .concat(vibrant_wf(fasta_validation_wf.out, vibrant_DB))
                    .concat(virnet_wf(fasta_validation_wf.out, virnet_deps))
                    .filter { it != 'deactivated' } // removes deactivated tool channels
                    .groupTuple()
                    
        filter_tool_names(results) 
                     
    //plotting results
        r_plot(filter_tool_names.out)
        upsetr_plot(filter_tool_names.out)
    //samtools 
        samtools(fasta_validation_wf.out.join(filter_tool_names.out))   
    //annotation  
        phage_annotation_wf(samtools.out, pvog_DB, vog_DB, rvdb_DB)
    }
   
    
    if (!params.setup && !params.fasta && params.fastq) {
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
        // COMMENT: all fastas have the same name which does name collision 
       //samtools(read_validation_wf.out.groupTuple(remainder: true).join(results)) 
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
    ${c_yellow}Usage examples:${c_reset}
    nextflow run replikation/What_the_Phage --fasta '*/*.fasta' --cores 20 \\
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
      local
      lsf
      ebi
      ${c_blue}Engines${c_reset} (choose one):
      docker
      singularity

    ${c_yellow}Options:${c_reset}
    --filter            min contig size [bp] to analyse [default: $params.filter]
    --cores             max cores for local use [default: $params.cores]
    --output            name of the result folder [default: $params.output]

    ${c_yellow}Tool control:${c_reset}
    Deactivate tools individually by adding one or more of these flags
    --dv                deactivates deepvirfinder
    --ma                deactivates marvel
    --mp                deactivates metaphinder
    --pp                deactivates PPRmeta
    --sm                deactivates sourmash
    --vb                deactivates vibrant
    --vf                deactivates virfinder
    --vn                deactivates virnet
    --vs                deactivates virsorter
    --anno              skips annotation

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
        log.info ( workflow.success ? "\nDone! Results are stored here --> $params.output \n" : "Oops .. something went wrong" )
    }
}