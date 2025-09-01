include { phabox2_identify } from './process/phabox2/phabox2_identify'


workflow phabox_wf {
    take:   fasta
            checkV completenes and likelyhood  threshold
    main:   if (!params.pb) { 
                        
                    phabox2_identify(fasta)


                    filter_phabox2_identify(phabox2_identify.out.phabox_results_ch)
                    phabox2_collect_data(phabox2_identify.out.phabox_collect_raw_ch)

                    // result channel
                    phabox2_identify_results = filter_phabox2_identify.out
                    }

            else { phabox2_identify_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   phabox2_identify_results
} 



