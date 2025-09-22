include { deepvirfinder } from './process/deepvirfinder/deepvirfinder'
include { filter_deepvirfinder } from './process/deepvirfinder/filter_deepvirfinder'
include { deepvirfinder_collect_data } from './process/deepvirfinder/deepvirfinder_collect_data'

include { metaphinder_own_DB } from './process/metaphinder_own_DB/metaphinder_own_DB'
include { filter_metaphinder_own_DB } from './process/metaphinder_own_DB/filter_metaphinder_own_DB'
include { metaphinder_collect_data_ownDB } from './process/metaphinder_own_DB/metaphinder_collect_data_own_db'
include { phage_references_blastDB } from './process/metaphinder_own_DB/phage_references_blastDB'
include { download_references } from './process/metaphinder_own_DB/download_references' 

include { metaphinder } from './process/metaphinder/metaphinder'
include { filter_metaphinder } from './process/metaphinder/filter_metaphinder'
include { metaphinder_collect_data } from './process/metaphinder/metaphinder_collect_data'

include { phabox2_identify } from './process/phabox2/phabox2_identify'
include { filter_phabox2_identify } from './process/phabox2/filter_phabox2'
include { phabox2_identify_collect_data } from './process/phabox2/phabox2_collect_data'

include { phigaro } from './process/phigaro/phigaro'
include { phigaro_collect_data } from './process/phigaro/phigaro_collect_data'

include { pprmeta } from './process/pprmeta/pprmeta'
include { filter_PPRmeta } from './process/pprmeta/filter_PPRmeta'
include { pprmeta_collect_data } from './process/pprmeta/pprmeta_collect_data'
include { ppr_download_dependencies } from './process/pprmeta/ppr_download_dependencies'

include { seeker } from './process/seeker/seeker'
include { filter_seeker } from './process/seeker/filter_seeker'
include { seeker_collect_data } from './process/seeker/seeker_collect_data'

include { sourmash } from './process/sourmash/sourmash'
include { filter_sourmash } from './process/sourmash/filter_sourmash'
include { sourmash_collect_data } from './process/sourmash/sourmash_collect_data'
include { sourmash_identify_DB_build } from './process/sourmash/sourmash_identify_DB_build'
include { split_multi_fasta } from './process/sourmash/split_multi_fasta'
include { download_references_NCBI_identify } from './process/sourmash/download_references'

include { vibrant_virome } from './process/vibrant_virome/vibrant_virome'
include { filter_vibrant_virome } from './process/vibrant_virome/filter_vibrant_virome'
include { vibrant_virome_collect_data } from './process/vibrant_virome/vibrant_virome_collect_data'
include { vibrant_download_DB; vibrant_download_DB as vibrant_virome_download_DB } from './process/vibrant_virome/vibrant_download_DB'

include { vibrant } from './process/vibrant/vibrant'
include { filter_vibrant } from './process/vibrant/filter_vibrant'
include { vibrant_collect_data } from './process/vibrant/vibrant_collect_data'
//include { vibrant_download_DB } from './process/vibrant/vibrant_download_DB' // ALREADY INCLUDED

include { virfinder } from './process/virfinder/virfinder'
include { filter_virfinder } from './process/virfinder/filter_virfinder'
include { virfinder_collect_data } from './process/virfinder/virfinder_collect_data'

include { virnet } from './process/virnet/virnet'
include { filter_virnet } from './process/virnet/filter_virnet'
include { virnet_collect_data } from './process/virnet/virnet_collect_data'
include { normalize_contig_size } from './process/virnet/normalize_contig_size'

include { virsorter_virome } from './process/virsorter_virome/virsorter_virome'
include { filter_virsorter_virome } from './process/virsorter_virome/filter_virsorter_virome'
include { virsorter_virome_collect_data } from './process/virsorter_virome/virsorter_virome_collect_data'
include { virsorter_download_DB; virsorter_download_DB as virsorter_virome_download_DB } from './process/virsorter_virome/virsorter_download_DB'

include { virsorter } from './process/virsorter/virsorter'
include { filter_virsorter } from './process/virsorter/filter_virsorter'
include { virsorter_collect_data } from './process/virsorter/virsorter_collect_data'
// include { virsorter_download_DB } from './process/virsorter/virsorter_download_DB' // ALREADY INCLUDED

include { virsorter2 } from './process/virsorter2/virsorter2'
include { filter_virsorter2 } from './process/virsorter2/filter_virsorter2'
include { virsorter2_collect_data } from './process/virsorter2/virsorter2_collect_data'
include { virsorter2_download_DB } from './process/virsorter2/virsorter2_download_DB'

// prepare results
include { filter_tool_names } from './process/prepare_results/filter_tool_names'
include { upsetr_plot } from './process/prepare_results/upsetr'
include { hue_heatmap } from './process/prepare_results/hue_heatmap'
include { contigs_by_tools } from './process/prepare_results/contigs_by_tools'

workflow identification_wf {
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

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////


                if (!params.mp) {
                // download references for blast db build
                download_references()

                // blast db build
                phage_references_blastDB(download_references.out)

                // tool prediction
                metaphinder_own_DB(fasta, phage_references_blastDB.out)
                // filtering
                filter_metaphinder_own_DB(metaphinder_own_DB.out[0].groupTuple(remainder: true))
                // raw data collector
                metaphinder_collect_data_ownDB(metaphinder_own_DB.out[1].groupTuple(remainder: true))
                // result channel
                metaphinder_own_db_results = filter_metaphinder_own_DB.out
                }
                else { metaphinder_own_db_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////
                if (!params.mp) { 
                            metaphinder(fasta)
                            // filtering
                            filter_metaphinder(metaphinder.out[0].groupTuple(remainder: true))
                            // raw data collector
                            metaphinder_collect_data(metaphinder.out[1].groupTuple(remainder: true))
                            // result channel
                            metaphinder_results = filter_metaphinder.out
                            }
                else { metaphinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.pb2) { 
                            
                        phabox2_identify(fasta)
                        result_filter_input_ch = phabox2_identify.out.phabox2_results_ch
                        collect_data_ch = phabox2_identify.out.phabox2_collect_raw_ch

                        filter_phabox2_identify(result_filter_input_ch)
                        phabox2_identify_collect_data(collect_data_ch)

                        // result channel
                        phabox2_identify_results = filter_phabox2_identify.out
                        }

                else { phabox2_identify_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.ph) { 
                            phigaro(fasta)
                            // raw data collector
                            phigaro_collect_data(phigaro.out[1].groupTuple(remainder: true))
                            // result channel // [0] emits filtered positive phage sequences (provided by DEV)
                            phigaro_results = phigaro.out[0]
                            }
                else { phigaro_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.pp) { 
                    ppr_download_dependencies()
                    // cloud storage via db_preload.exists()
                    
                    filter_PPRmeta(pprmeta(fasta, ppr_download_dependencies.out).groupTuple(remainder: true))
                    // raw data collector
                    pprmeta_collect_data(pprmeta.out.groupTuple(remainder: true))
                    // result channel
                    pprmeta_results = filter_PPRmeta.out
                    }
                else { pprmeta_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
                
                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.sk) {
                            // run and filter seeker
                            filter_seeker(seeker(fasta).groupTuple(remainder: true))
                            // raw data collector
                            seeker_collect_data(seeker.out.groupTuple(remainder: true))
                            // results channel
                            seeker_results = filter_seeker.out		
                            }
                else { seeker_results = Channel.from( ['deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.sm) {
                        // local storage via storeDir
                        download_references_NCBI_identify()
                        
                        // sourmash db build    
                        sourmash_identify_DB_build(download_references_NCBI_identify.out) 
                        
                        // sourmash prediction
                        filter_sourmash(sourmash(split_multi_fasta(fasta), sourmash_identify_DB_build.out).groupTuple(remainder: true))
                        // raw data collector
                        sourmash_collect_data(sourmash.out.groupTuple(remainder: true))
                        // result channel
                        sourmash_identify_results = filter_sourmash.out
                        }
                else { sourmash_identify_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vb && !params.virome) {
                        // local storage via storeDir
                        vibrant_virome_download_DB()
                        // tool prediction
                        vibrant_virome(fasta, vibrant_virome_download_DB.out)
                        // filtering
                        filter_vibrant_virome(vibrant_virome.out[0].groupTuple(remainder: true))
                        // raw data collector
                        vibrant_virome_collect_data(vibrant_virome.out[1].groupTuple(remainder: true))
                        // result channel
                        vibrant_virome_results = filter_vibrant_virome.out
                        }
                else { vibrant_virome_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vb) {
                        // local storage via storeDir
                        vibrant_download_DB()
                        // tool prediction
                        vibrant(fasta, vibrant_download_DB.out)
                        // filtering
                        filter_vibrant(vibrant.out[0].groupTuple(remainder: true))
                        // raw data collector
                        vibrant_collect_data(vibrant.out[1].groupTuple(remainder: true))
                        // result channel
                        vibrant_results = filter_vibrant.out
                        }
                else { vibrant_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
                
                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vf) { 
                            filter_virfinder(virfinder(fasta).groupTuple(remainder: true))
                            // raw data collector
                            virfinder_collect_data(virfinder.out.groupTuple(remainder: true))
                            // result channel
                            virfinder_results = filter_virfinder.out
                            }
                else { virfinder_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vn) { 
                            filter_virnet(virnet(normalize_contig_size(fasta)).groupTuple(remainder: true))
                            // raw data collector
                            virnet_collect_data(virnet.out.groupTuple(remainder: true))
                            // result channel
                            virnet_results = filter_virnet.out
                            }
                else { virnet_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
                
                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vs && !params.virome) {
                    // local storage via storeDir
                    virsorter_virome_download_DB()
                    // tool prediction
                    virsorter_virome(fasta, virsorter_virome_download_DB.out)
                    // filtering
                    filter_virsorter_virome(virsorter_virome.out[0].groupTuple(remainder: true))
                    // raw data collector
                    virsorter_virome_collect_data(virsorter_virome.out[1].groupTuple(remainder: true))
                    // result channel
                    virsorter_virome_results = filter_virsorter_virome.out
                    }
                else { virsorter_virome_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vs) {
                    // local storage via storeDir
                    virsorter_download_DB()
                    // tool prediction
                    virsorter(fasta, virsorter_download_DB.out)
                    // filtering
                    filter_virsorter(virsorter.out[0].groupTuple(remainder: true))
                    // raw data collector
                    virsorter_collect_data(virsorter.out[1].groupTuple(remainder: true))
                    // result channel
                    virsorter_results = filter_virsorter.out
                    }
                else { virsorter_results = Channel.from( [ 'deactivated', 'deactivated'] ) }

                ///////////////////////////////////////////////////////////////
                /////
                ///////////////////////////////////////////////////////////////

                if (!params.vs2) { 

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



                // collect all tools
                if (params.fasta  && params.identify && !params.annotate_taxonomy && !params.setup && params.all_tools|| params.fasta && params.all_tools && !params.identify && !params.annotate_taxonomy && !params.setup )  { 
                results = deepvirfinder_results
                    .concat( phigaro_results )
                    .concat( seeker_results )
                    .concat( virfinder_results )
                    .concat( virnet_results )
                    .concat( pprmeta_results )
                    .concat( metaphinder_results )
                    .concat( metaphinder_own_db_results )
                    .concat( vibrant_results )
                    .concat( vibrant_virome_results )
                    .concat( virsorter_results )
                    .concat( virsorter_virome_results )
                    .concat( virsorter2_results )
                    .concat( sourmash_identify_results )
                    .concat( phabox2_identify_results )
                    .filter { it != 'deactivated' } // removes deactivated tool channels
                    .groupTuple()
                }
                // collect benchmarked tools
                else {
                results = deepvirfinder_results
                    .concat( seeker_results )
                    .concat( virfinder_results )
                    .concat( pprmeta_results )
                    .concat( metaphinder_results )
                    .concat( vibrant_results )
                    .concat( vibrant_virome_results )
                    .concat( virsorter_results )
                    .concat( virsorter_virome_results )
                    .concat( virsorter2_results )
                    .filter { it != 'deactivated' } // removes deactivated tool channels
                    .groupTuple()
                }

                //plotting overview
                    filter_tool_names(results)
                    upsetr_plot(filter_tool_names.out[0])
                    contigs_by_tools(results)

                // markdown report collecter
                    heatmap_table_markdown_input = contigs_by_tools.out.overview_ch//.join(contigs_by_tools.out.tool_agreements_per_contig_ch)
                    upsetr_plot_markdown_input = upsetr_plot.out

                identify_markdown_input= upsetr_plot_markdown_input.join(heatmap_table_markdown_input) // name, upsetr_plot_markdown_input heatmap_table_markdown_input

        emit:   identify_markdown_input
                
} 