include { phabox2_identify } from './process/phabox2/phabox2_identify'
include { filter_phabox2_identify } from './process/phabox2/filter_phabox2'
include { phabox2_identify_collect_data } from './process/phabox2/phabox2_collect_data'


workflow phabox2_identify_wf {
    take:   fasta
            
    main:   if (!params.pb2) { 
                        
                    phabox2_identify(fasta)
                    result_filter_input_ch = phabox2_identify.out.phabox2_results_ch
                    collect_data_ch = phabox2_identify.out.phabox2_collect_raw_ch

                    filter_phabox2_identify(result_filter_input_ch)
                    phabox2_identify_collect_data(collect_data_ch)

                    // result channel
                    phabox2_identify_results = filter_phabox2_identify.out
                    }

            else { phabox2_identify_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   phabox2_identify_results
} 



