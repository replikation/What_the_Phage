include { metaphinder_own_DB } from './process/metaphinder_own_DB/metaphinder_own_DB'
include { filter_metaphinder } from './process/metaphinder_own_DB/filter_metaphinder_own_DB'
include { metaphinder_collect_data_ownDB } from './process/metaphinder_own_DB/metaphinder_collect_data_own_db'
include { blast_db } from './process/metaphinder_own_DB/phage_references_blastDB'


workflow metaphinder_own_DB_wf {
    take:   fasta
    main:   if (!params.mp) {
                        blast_db
                        metaphinder_own_DB(fasta, blast_db())
                        // filtering
                        filter_metaphinder_own_DB(metaphinder_own_DB.out[0].groupTuple(remainder: true))
                        // raw data collector
                        metaphinder_collect_data_ownDB(metaphinder_own_DB.out[1].groupTuple(remainder: true))
                        // result channel
                        metaphinder_results = filter_metaphinder_own_DB.out
                        }
            else { metaphinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_own_db_results 
} 