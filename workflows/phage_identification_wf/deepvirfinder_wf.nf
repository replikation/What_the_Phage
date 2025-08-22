include { deepvirfinder } from './process/deepvirfinder/deepvirfinder'
include { filter_deepvirfinder } from './process/deepvirfinder/filter_deepvirfinder'
include { deepvirfinder_collect_data } from './process/deepvirfinder/deepvirfinder_collect_data'

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