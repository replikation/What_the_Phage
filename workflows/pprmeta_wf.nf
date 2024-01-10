include { pprmeta } from './process/pprmeta/pprmeta'
include { filter_PPRmeta } from './process/pprmeta/filter_PPRmeta'
include { pprmeta_collect_data } from './process/pprmeta/pprmeta_collect_data'
include { ppr_download_dependencies } from './process/pprmeta/ppr_download_dependencies'

workflow pprmeta_wf {
    take:   fasta
    main:   if (!params.pp) { 
                ppr_download_dependencies()
                // cloud storage via db_preload.exists()
                
                filter_PPRmeta(pprmeta(fasta, ppr_download_dependencies.out).groupTuple(remainder: true))
                // raw data collector
                pprmeta_collect_data(pprmeta.out.groupTuple(remainder: true))
                // result channel
                pprmeta_results = filter_PPRmeta.out
                }
            else { pprmeta_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   pprmeta_results 
} 