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

//get-citation-file for results
    citation = Channel.fromPath(workflow.projectDir + "/docs/Citations.bib")
            .collectFile(storeDir: params.output + "/literature")

/************* 
* MODULES
*************/

    include { checkV } from './modules/checkV'
    include { chromomap } from './modules/chromomap'
    include { chromomap_parser } from './modules/parser/chromomap_parser'
    include { deepvirfinder } from './modules/tools/deepvirfinder'
    include { deepvirfinder_collect_data } from './modules/raw_data_collection/deepvirfinder_collect_data'
    include { download_checkV_DB } from './modules/databases/download_checkV_DB'
    include { download_references } from './modules/databases/download_references'
    include { fastqTofasta } from './modules/fastqTofasta'
    include { filter_PPRmeta } from './modules/parser/filter_PPRmeta'
    include { filter_deepvirfinder } from './modules/parser/filter_deepvirfinder'
    include { filter_marvel } from './modules/parser/filter_marvel'
    include { filter_sourmash } from './modules/parser/filter_sourmash'
    include { filter_tool_names } from './modules/parser/filter_tool_names'
    include { filter_virfinder } from './modules/parser/filter_virfinder'
    include { filter_virnet } from './modules/parser/filter_virnet'
    include { hmmscan } from './modules/hmmscan'
    include { input_suffix_check } from './modules/input_suffix_check'
    include { marvel } from './modules/tools/marvel'
    include { marvel_collect_data } from './modules/raw_data_collection/marvel_collect_data'
    include { normalize_contig_size } from './modules/normalize_contig_size'
    include { parse_reads } from './modules/parser/parse_reads.nf'
    include { phage_references_blastDB } from './modules/databases/phage_references_blastDB'
    include { ppr_download_dependencies } from './modules/databases/ppr_download_dependencies'
    include { pprmeta } from './modules/tools/pprmeta'
    include { pprmeta_collect_data } from './modules/raw_data_collection/pprmeta_collect_data'
    include { prodigal } from './modules/prodigal'
    include { pvog_DB; vogtable_DB } from './modules/databases/download_pvog_DB'
    include { r_plot } from './modules/r_plot.nf' 
    include { r_plot_reads } from './modules/r_plot_reads.nf'
    include { removeSmallReads } from './modules/removeSmallReads'
    include { rvdb_DB } from './modules/databases/download_rvdb_DB'
    include { samtools } from './modules/samtools'
    include { seqkit } from './modules/seqkit'
    include { setup_container } from './modules/setup_container'
    include { shuffle_reads_nts } from './modules/shuffle_reads_nts'
    include { sourmash } from './modules/tools/sourmash'
    include { sourmash_collect_data } from './modules/raw_data_collection/sourmash_collect_data'
    include { sourmash_download_DB } from './modules/databases/sourmash_download_DB'
    include { sourmash_for_tax } from './modules/sourmash_for_tax'
    include { split_multi_fasta } from './modules/split_multi_fasta'
    include { testprofile } from './modules/testprofile'
    include { upsetr_plot } from './modules/upsetr.nf'
    include { vibrant_download_DB } from './modules/databases/vibrant_download_DB'
    include { virfinder } from './modules/tools/virfinder'
    include { virfinder_collect_data } from './modules/raw_data_collection/virfinder_collect_data'
    include { virnet } from './modules/tools/virnet'
    include { virnet_collect_data } from './modules/raw_data_collection/virnet_collect_data'
    include { virsorter_download_DB } from './modules/databases/virsorter_download_DB'
    include { vog_DB } from './modules/databases/download_vog_DB'
    include { filter_metaphinder; filter_metaphinder_own_DB } from './modules/parser/filter_metaphinder'
    include { filter_vibrant; filter_vibrant_virome } from './modules/parser/filter_vibrant'
    include { filter_virsorter; filter_virsorter_virome } from './modules/parser/filter_virsorter' 
    include { metaphinder; metaphinder_own_DB} from './modules/tools/metaphinder'
    include { metaphinder_collect_data; metaphinder_collect_data_ownDB } from './modules/raw_data_collection/metaphinder_collect_data'
    include { vibrant; vibrant_virome } from './modules/tools/vibrant'
    include { vibrant_collect_data; vibrant_virome_collect_data } from './modules/raw_data_collection/vibrant_collect_data'
    include { virsorter; virsorter_virome } from './modules/tools/virsorter'
    include { virsorter_collect_data; virsorter_virome_collect_data } from './modules/raw_data_collection/virsorter_collect_data'
    include { phigaro } from './modules/tools/phigaro'
    include { phigaro_collect_data } from './modules/raw_data_collection/phigaro_collect_data'
    include { virsorter2 } from './modules/tools/virsorter2'
    include { virsorter2_download_DB } from './modules/databases/virsorter2_download_DB' 
    include { filter_virsorter2 } from './modules/parser/filter_virsorter2'
    include { virsorter2_collect_data} from './modules/raw_data_collection/virsorter2_collect_data'
    include { seeker } from './modules/tools/seeker'
    include { filter_seeker } from './modules/parser/filter_seeker'
    include { seeker_collect_data } from './modules/raw_data_collection/seeker_collect_data'

/************* 
* DATABASES for Phage Identification
*************/
workflow ppr_dependecies {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { ppr_download_dependencies(); db = ppr_download_dependencies.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/pprmeta/PPR-Meta", type: 'dir')
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
            db_preload = file("${params.databases}/virsorter/virsorter-data", type: 'dir')
            if (db_preload.exists()) { db = db_preload }
            else  { virsorter_download_DB(); db = virsorter_download_DB.out } 
        }
    emit: db
}

workflow virsorter2_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { virsorter2_download_DB(); db = virsorter2_download_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/virsorter2-db", type: 'dir')
            if (db_preload.exists()) { db = db_preload }
            else  { virsorter2_download_DB(); db = virsorter2_download_DB.out } 
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
            db_preload = file("${params.databases}/sourmash/phages.sbt.zip")
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
            db_preload = file("${params.databases}/blast_DB_phage/blast_database.tar.gz", type: 'dir')
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

/************* 
* DATABASES for Phage annotation
*************/

workflow pvog_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { pvog_DB(); db = pvog_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/pvogs/", type: 'dir')
            if (db_preload.exists()) { db = db_preload }
            else  { pvog_DB(); db = pvog_DB.out } 
        }
    emit: db
}

workflow vogtable_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { vogtable_DB(); db = vogtable_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/vog_table/VOGTable.txt")
            if (db_preload.exists()) { db = db_preload }
            else  { vogtable_DB(); db = vogtable_DB.out } 
        }
    emit: db
}

workflow rvdb_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { rvdb_DB(); db = rvdb_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/rvdb", type: 'dir')
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
            db_preload = file("${params.databases}/vog/vogdb", type: 'dir')
            if (db_preload.exists()) { db = db_preload }
            else  { vog_DB(); db = vog_DB.out } 
        }
    emit: db
}

workflow checkV_database {
    main: 
        // local storage via storeDir
        if (!params.cloudProcess) { download_checkV_DB(); db = download_checkV_DB.out }
        // cloud storage via db_preload.exists()
        if (params.cloudProcess) {
            db_preload = file("${params.databases}/checkV/checkv-db-v0.6", type: 'dir')
            if (db_preload.exists()) { db = db_preload }
            else  { download_checkV_DB(); db = download_checkV_DB.out } 
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

workflow virsorter_virome_wf {
    take:   fasta
            virsorter_DB
    main:   if (!params.vs && !params.virome) {
                        virsorter_virome(fasta, virsorter_DB)
                        // filtering
                        filter_virsorter_virome(virsorter_virome.out[0].groupTuple(remainder: true))
                        // raw data collector
                        virsorter_virome_collect_data(virsorter_virome.out[1].groupTuple(remainder: true))
                        // result channel
                        virsorter_virome_results = filter_virsorter_virome.out
                        }
            else { virsorter_virome_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virsorter_virome_results
} 

workflow virsorter2_wf {
    take:   fasta           
            virsorter2_download_DB
    main:   if (!params.vs2) { 
                        virsorter2(fasta, virsorter2_download_DB)
                        // filtering
                        filter_virsorter2(virsorter2.out[0].groupTuple(remainder: true))
                        // raw data collector
                        virsorter2_collect_data(virsorter2.out[1].groupTuple(remainder: true))
                        // result channel
                        virsorter2_results = filter_virsorter2.out
                        }
            else { virsorter2_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virsorter2_results
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

workflow vibrant_virome_wf {
    take:   fasta
            vibrant_download_DB
    main:   if (!params.vb && !params.virome) {
                        vibrant_virome(fasta, vibrant_download_DB)
                        // filtering
                        filter_vibrant_virome(vibrant_virome.out[0].groupTuple(remainder: true))
                        // raw data collector
                        vibrant_virome_collect_data(vibrant_virome.out[1].groupTuple(remainder: true))
                        // result channel
                        vibrant_virome_results = filter_vibrant_virome.out
                        }
            else { vibrant_virome_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   vibrant_virome_results
}

workflow virnet_wf {
    take:   fasta

    main:   if (!params.vn) { 
                        filter_virnet(virnet(normalize_contig_size(fasta)).groupTuple(remainder: true))
                        // raw data collector
                        virnet_collect_data(virnet.out.groupTuple(remainder: true))
                        // result channel
                        virnet_results = filter_virnet.out
                        }
            else { virnet_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virnet_results
} 

workflow phigaro_wf {
    take:   fasta
    main:   if (!params.ph) { 
                        phigaro(fasta)
                        // raw data collector
                        phigaro_collect_data(phigaro.out[1].groupTuple(remainder: true))
                        // result channel // [0] emits filtered positive phage sequences (provided by DEV)
                        phigaro_results = phigaro.out[0]
                        }
            else { phigaro_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   phigaro_results
}

workflow seeker_wf {
	take:	fasta
	main:	if (!params.sk) {
                        // run and filter seeker
                        filter_seeker(seeker(fasta).groupTuple(remainder: true))
                        // raw data collector
                        seeker_collect_data(seeker.out.groupTuple(remainder: true))
                        // results channel
                        seeker_results = filter_seeker.out		
                        }
            else { seeker_results = Channel.from( ['deactivated', 'deactivated'] ) }
    emit:   seeker_results
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
        if (!params.annotate) {
            phage_references() 
            ref_phages_DB = phage_blast_DB (phage_references.out)
            ppr_deps = ppr_dependecies()
            sourmash_DB = sourmash_database (phage_references.out)
            vibrant_DB = vibrant_download_DB()
            virsorter_DB = virsorter_database()
            virsorter2_DB = virsorter2_download_DB()
        }
        if (!params.identify) {
            vog_table = vogtable_database()
            pvog_DB = pvog_database() 
            vog_DB = vog_database() 
            rvdb_DB = rvdb_database()
            checkV_DB = checkV_database()
        }
} 

workflow checkV_wf {
    take:   fasta
            database
    main:   checkV(fasta, database)

            /* filter_tool_names.out in identify_fasta_MSF is the info i need to parse into checkV overview 
            has tuple val(name), file("*.txt")
            
            each txt file can be present or not

            1.) parse this output into a "contig name", 1, 0" matrix still having the "value" infront of it

            2.) then i could do a join first bei val(name), an then combine by val(contigname) within the channels?

            3.) annoying ...

            */
    emit:   checkV.out
} 

workflow get_test_data {
    main: testprofile()
    emit: testprofile.out.flatten().map { file -> tuple(file.simpleName, file) } // or getSimpleName
}

workflow phage_tax_classification {
    take:   fasta
            sourmash_database
    main:    
            sourmash_for_tax(split_multi_fasta(fasta), sourmash_database).groupTuple(remainder: true)
}

/************* 
* MainSubWorkflows
*************/

workflow identify_fasta_MSF {
    take:   fasta
            ref_phages_DB
            ppr_deps
            sourmash_DB
            vibrant_DB
            virsorter_DB
            virsorter2_DB
    main: 
        // input filter  
        fasta_validation_wf(fasta)

        // gather results
            results =   virsorter_wf(fasta_validation_wf.out, virsorter_DB)
                        .concat(virsorter2_wf(fasta_validation_wf.out, virsorter2_DB))
                        .concat(virsorter_virome_wf(fasta_validation_wf.out, virsorter_DB))
                        .concat(marvel_wf(fasta_validation_wf.out))      
                        .concat(sourmash_wf(fasta_validation_wf.out, sourmash_DB))
                        .concat(metaphinder_wf(fasta_validation_wf.out))
                        .concat(metaphinder_own_DB_wf(fasta_validation_wf.out, ref_phages_DB))
                        .concat(deepvirfinder_wf(fasta_validation_wf.out))
                        .concat(virfinder_wf(fasta_validation_wf.out))
                        .concat(pprmeta_wf(fasta_validation_wf.out, ppr_deps))
                        .concat(vibrant_wf(fasta_validation_wf.out, vibrant_DB))
                        .concat(vibrant_virome_wf(fasta_validation_wf.out, vibrant_DB))
                        .concat(virnet_wf(fasta_validation_wf.out))
                        .concat(phigaro_wf(fasta_validation_wf.out))
                        .concat(seeker_wf(fasta_validation_wf.out))
                        .filter { it != 'deactivated' } // removes deactivated tool channels
                        .groupTuple()
                        
            filter_tool_names(results) 
                                               
        //plotting results
            r_plot(filter_tool_names.out)
            upsetr_plot(filter_tool_names.out)
        //samtools 
            samtools(fasta_validation_wf.out.join(filter_tool_names.out))

    emit:   samtools.out
}

workflow identify_fastq_MSF { 
    take:   fastq
            ref_phages_DB
            ppr_deps
            sourmash_DB
            vibrant_DB
            virsorter_DB
    main:
    // input filter
        read_validation_wf(fastq)
   
    // gather results
        results =   metaphinder_wf(read_validation_wf.out)
                    .concat(metaphinder_own_DB_wf(read_validation_wf.out, ref_phages_DB))
                    .concat(virfinder_wf(read_validation_wf.out))
                    .concat(pprmeta_wf(read_validation_wf.out, ppr_deps))
                    .filter { it != 'deactivated' } // removes deactivated tool channels
                    .groupTuple()
        
        filter_tool_names(results) 

    //plotting results
        r_plot_reads(parse_reads(results))
        upsetr_plot(filter_tool_names.out)
    
    //samtools
        // COMMENT: all fastas have the same name which does name collision 
       samtools(read_validation_wf.out.groupTuple(remainder: true).join(results)) 

    emit: samtools.out
}

workflow phage_annotation_MSF {
    take :  fasta 
            pvog_DB
            vog_table
            vog_DB
            rvdb_DB
    main :  
            //annotation-process
            prodigal(fasta)      

            hmmscan(prodigal.out, pvog_DB)

            chromomap_parser(
                    fasta.join(hmmscan.out), vog_table)

            chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))
}

/************* 
* MAIN WORKFLOWS
*************/

workflow {
// SETUP AND TESTRUNS
if (params.setup) { setup_wf() }
else {
    if (workflow.profile.contains('test') && !workflow.profile.contains('smalltest')) { fasta_input_ch = get_test_data() }
    if (workflow.profile.contains('smalltest') ) 
        { fasta_input_ch = Channel.fromPath(workflow.projectDir + "/test-data/all_pos_phage.fa", checkIfExists: true).map { file -> tuple(file.simpleName, file) }.view() }
// DATABASES
    // identification
    phage_references() 
    if (params.mp || params.annotate) { ref_phages_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { ref_phages_DB = phage_blast_DB(phage_references.out) }
    if (params.pp || params.annotate) { ppr_deps = Channel.from( [ 'deactivated', 'deactivated'] ) } else { ppr_deps = ppr_dependecies() }
    if (params.vb || params.annotate) { vibrant_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { vibrant_DB = vibrant_database() }
    if (params.vs || params.annotate) { virsorter_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { virsorter_DB = virsorter_database() }
    if (params.vs2 || params.annotate) { virsorter2_DB = Channel.from( ['deactivated', 'deactivated'] ) } else { virsorter2_DB = virsorter2_database() }
    //  annotation
    if (params.identify) { pvog_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { pvog_DB = pvog_database() }
    if (params.identify) { vog_table = Channel.from( [ 'deactivated', 'deactivated'] ) } else { vog_table = vogtable_database() }
    if (params.identify) { vog_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { vog_DB = vog_database() }
    if (params.identify) { rvdb_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { rvdb_DB = rvdb_database() }
    if (params.identify) { checkV_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { checkV_DB = checkV_database() }
    // sourmash (used in identify and annotate)
    if (params.identify && params.sm) { sourmash_DB = Channel.from( [ 'deactivated', 'deactivated'] ) } else { sourmash_DB = sourmash_database(phage_references.out) }

// IDENTIFY !
    if (params.fasta && !params.annotate) { identify_fasta_MSF(fasta_input_ch, ref_phages_DB, ppr_deps,sourmash_DB, vibrant_DB, virsorter_DB, virsorter2_DB) }
    if (params.fastq) { identify_fastq_MSF(fastq_input_ch, ref_phages_DB, ppr_deps, sourmash_DB, vibrant_DB, virsorter_DB) }

// ANNOTATE & TAXONOMY !
    // generate "annotation_ch" based on input types (fasta/fastq and annotate)
    if (params.fasta && params.fastq && params.annotate) { annotation_ch = identify_fastq_MSF.out.mix(fasta_validation_wf(fasta_input_ch)) }
    else if (params.fasta && params.fastq && !params.annotate) { annotation_ch = identify_fastq_MSF.out.mix(identify_fasta_MSF.out) }
    else if (params.fasta && params.annotate) { annotation_ch = fasta_validation_wf(fasta_input_ch)}
    else if (params.fasta && !params.annotate) { annotation_ch = identify_fasta_MSF.out }
    else if (params.fastq ) { annotation_ch = identify_fastq_MSF.out }

    // Annotation & classification from this -> annotation_ch = tuple val(name), path(fasta)
    if (!params.identify) { 
        phage_annotation_MSF(annotation_ch, pvog_DB, vog_table, vog_DB, rvdb_DB) 
        checkV_wf(annotation_ch, checkV_DB) 
        phage_tax_classification(annotation_ch, sourmash_DB )
    }
}}

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
    --ma                deactivates marvel
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
