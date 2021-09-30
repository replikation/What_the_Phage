include { vibrant } from './process/vibrant/vibrant'
include { filter_vibrant } from './process/vibrant/filter_vibrant'
include { vibrant_collect_data } from './process/vibrant/vibrant_collect_data'
include { vibrant_download_DB } from './process/vibrant/vibrant_download_DB'

workflow vibrant_wf {
    take:   fasta       
    main:    if (!params.vb) {
                    // local storage via storeDir
                    if (!params.cloudProcess) { vibrant_download_DB(); db = vibrant_download_DB.out }
                    //cloud storage via db_preload.exists()
                    if (params.cloudProcess) {
                    db_preload = file("${params.databases}/Vibrant/database.tar.gz")
                    if (db_preload.exists()) { db = db_preload }
                    else  { vibrant_download_DB(); db = vibrant_download_DB.out } 
                    }
                    // tool prediction
                    vibrant(fasta, vibrant_download_DB.out)
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