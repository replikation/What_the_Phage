include { metaphinder } from './process/metaphinder/metaphinder'
include { filter_metaphinder } from './process/metaphinder/filter_metaphinder'
include { metaphinder_collect_data } from './process/metaphinder/metaphinder_collect_data'

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