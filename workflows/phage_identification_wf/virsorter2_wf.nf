include { virsorter2 } from './process/virsorter2/virsorter2'
include { filter_virsorter2 } from './process/virsorter2/filter_virsorter2'
include { virsorter2_collect_data } from './process/virsorter2/virsorter2_collect_data'
include { virsorter2_download_DB } from './process/virsorter2/virsorter2_download_DB'



workflow virsorter2_wf {
    take:   fasta           
    main:   if (!params.vs2) { 

                    // local storage via storeDir
                    virsorter2_download_DB()
                    // tool prediction
                    virsorter2(fasta, virsorter2_download_DB.out)
                    // filtering
                    filter_virsorter2(virsorter2.out[0].groupTuple(remainder: true))
                    // raw data collector
                    virsorter2_collect_data(virsorter2.out[1].groupTuple(remainder: true))
                    // result channel
                    virsorter2_results = filter_virsorter2.out
                    }
            else { virsorter2_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virsorter2_results
} 