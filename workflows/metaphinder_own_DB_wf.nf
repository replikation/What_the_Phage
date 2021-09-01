include { metaphinder_own_DB } from './process/metaphinder_own_DB/metaphinder_own_DB'
include { filter_metaphinder_own_DB } from './process/metaphinder_own_DB/filter_metaphinder_own_DB'
include { metaphinder_collect_data_ownDB } from './process/metaphinder_own_DB/metaphinder_collect_data_own_db'
include { phage_references_blastDB } from './process/metaphinder_own_DB/phage_references_blastDB'
include { download_references } from './process/metaphinder_own_DB/download_references' 

workflow metaphinder_own_DB_wf {
    take:   fasta
    main:   if (!params.mp) {
            // download references for blast db build
            // local storage via storeDir
            if (!params.cloudProcess) { download_references(); db = download_references.out }
            // cloud storage via db_preload.exists()
            if (params.cloudProcess) {
            db_preload = file("${params.databases}/references/phage_references.fa")
            if (db_preload.exists()) { db = db_preload }
            else  { download_references(); db = download_references.out } 
            }
            // blast db build
            // local storage via storeDir
            if (!params.cloudProcess) { phage_references_blastDB(download_references.out); db = phage_references_blastDB.out }
            // cloud storage via db_preload.exists()
            if (params.cloudProcess) {
            db_preload = file("${params.databases}/blast_DB_phage/blast_database.tar.gz", type: 'dir')
            if (db_preload.exists()) { db = db_preload }
            else  { phage_references_blastDB(references); db = phage_references_blastDB.out } 
            }
            // tool prediction
            metaphinder_own_DB(fasta, phage_references_blastDB.out)
            // filtering
            filter_metaphinder_own_DB(metaphinder_own_DB.out[0].groupTuple(remainder: true))
            // raw data collector
            metaphinder_collect_data_ownDB(metaphinder_own_DB.out[1].groupTuple(remainder: true))
            // result channel
            metaphinder_own_db_results = filter_metaphinder_own_DB.out
            }
            else { metaphinder_own_db_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_own_db_results 
} 