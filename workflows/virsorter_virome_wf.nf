include { virsorter_virome } from './process/virsorter_virome/virsorter_virome'
include { filter_virsorter_virome } from './process/virsorter_virome/filter_virsorter_virome'
include { virsorter_virome_collect_data } from './process/virsorter_virome/virsorter_virome_collect_data'
include { virsorter_download_DB } from './process/virsorter_virome/virsorter_download_DB'


workflow virsorter_virome_wf {
    take:   fasta
    main:   if (!params.vs && !params.virome) {
                // local storage via storeDir
                virsorter_download_DB()
                // tool prediction
                virsorter_virome(fasta, virsorter_download_DB.out)
                // filtering
                filter_virsorter_virome(virsorter_virome.out[0].groupTuple(remainder: true))
                // raw data collector
                virsorter_virome_collect_data(virsorter_virome.out[1].groupTuple(remainder: true))
                // result channel
                virsorter_virome_results = filter_virsorter_virome.out
                }
            else { virsorter_virome_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virsorter_virome_results
} 
