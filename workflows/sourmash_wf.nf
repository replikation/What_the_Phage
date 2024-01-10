include { sourmash } from './process/sourmash/sourmash'
include { filter_sourmash } from './process/sourmash/filter_sourmash'
include { sourmash_collect_data } from './process/sourmash/sourmash_collect_data'
include { sourmash_download_DB } from './process/sourmash/sourmash_download_DB'
include { split_multi_fasta } from './process/sourmash/split_multi_fasta'
include { download_references } from './process/sourmash/download_references'

workflow sourmash_wf {
    take:   fasta
    main:   
            if (!params.sm) {
                    // local storage via storeDir
                    download_references()
                    // sourmash db build    
                    sourmash_download_DB(download_references.out) 

                    // sourmash prediction
                    filter_sourmash(sourmash(split_multi_fasta(fasta), sourmash_download_DB.out).groupTuple(remainder: true))
                    // raw data collector
                    sourmash_collect_data(sourmash.out.groupTuple(remainder: true))
                    // result channel
                    sourmash_results = filter_sourmash.out
                    }
            else { sourmash_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

    emit:   sourmash_results
} 