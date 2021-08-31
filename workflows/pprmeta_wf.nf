include { pprmeta } from './process/pprmeta/'
include { filter_PPRmeta } from './process/pprmeta/'
include { pprmeta_collect_data } from './process/pprmeta/pprmeta_collect_data'
include { ppr_deps } from './process/pprmeta/ppr_download_dependencies'

workflow pprmeta_wf {
    take:   fasta
    main:   if (!params.pp) { 
                            if (!params.cloudProcess) { ppr_download_dependencies(); db = ppr_download_dependencies.out }
                            // cloud storage via db_preload.exists()
                            if (params.cloudProcess) {
                            db_preload = file("${params.databases}/pprmeta/PPR-Meta", type: 'dir')
                            if (db_preload.exists()) { db = db_preload }
                            else  { ppr_download_dependencies(); db = ppr_download_dependencies.out } 
                            }
                        filter_PPRmeta(pprmeta(fasta, ppr_download_dependencies.out).groupTuple(remainder: true))
                        // raw data collector
                        pprmeta_collect_data(pprmeta.out.groupTuple(remainder: true))
                        // result channel
                        pprmeta_results = filter_PPRmeta.out
                        }
            else { pprmeta_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   pprmeta_results 
} 