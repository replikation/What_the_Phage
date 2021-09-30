include { virfinder } from './process/virfinder/virfinder'
include { filter_virfinder } from './process/virfinder/filter_virfinder'
include { virfinder_collect_data } from './process/virfinder/virfinder_collect_data'


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
