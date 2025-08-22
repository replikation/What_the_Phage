include { vibrant } from './process/vibrant/vibrant'
include { filter_vibrant } from './process/vibrant/filter_vibrant'
include { vibrant_collect_data } from './process/vibrant/vibrant_collect_data'
include { vibrant_download_DB } from './process/vibrant/vibrant_download_DB'

workflow vibrant_wf {
    take:   fasta       
    main:    if (!params.vb) {
                    // local storage via storeDir
                    vibrant_download_DB()
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