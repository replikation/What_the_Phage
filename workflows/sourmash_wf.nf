include { sourmash } from './process/sourmash/'
include { filter_sourmash } from './process/sourmash/filter_seeker'
include { sourmash_collect_data } from './process/sourmash/sourmash_collect_data'
include { sourmash_database } from './process/sourmash/sourmash_download_DB'
include { split_multi_fasta } from './process/sourmash/split_multi_fasta'


workflow sourmash_wf {
    take:   fasta
    main:   
            if (!params.sm) { 
                        filter_sourmash(sourmash(split_multi_fasta(fasta), sourmash_database()).groupTuple(remainder: true))
                        // raw data collector
                        sourmash_collect_data(sourmash.out.groupTuple(remainder: true))
                        // result channel
                        sourmash_results = filter_sourmash.out
                        }
            else { sourmash_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

    emit:   sourmash_results
} 