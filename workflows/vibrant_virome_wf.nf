include { vibrant_virome } from './process/vibrant_virome/vibrant_virome'
include { filter_vibrant_virome } from './process/vibrant_virome/filter_vibrant_virome'
include { vibrant_virome_collect_data } from './process/vibrant_virome/vibrant_virome_collect_data'
include { vibrant_download_DB } from './process/vibrant_virome/vibrant_download_DB'

workflow vibrant_virome_wf {
    take:   fasta
    main:   if (!params.vb && !params.virome) {
                    // local storage via storeDir
                    vibrant_download_DB()
                    // tool prediction
                    vibrant_virome(fasta, vibrant_download_DB.out)
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