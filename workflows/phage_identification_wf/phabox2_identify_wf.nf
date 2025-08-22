include { phabox2_identify } from './process/phabox2/phabox2_identify'


workflow phabox_wf {
    take:   fasta
            checkV completenes and likelyhood  threshold
    main:   if (!params.pb) { 
                        
                        
                        phabox2_identify(fasta )

                        
                        filter_phabox2(metaphinder.out[0].groupTuple(remainder: true))
                        // raw data collector
                        // metaphinder_collect_data(metaphinder.out[1].groupTuple(remainder: true))
                        // result channel
                        // metaphinder_results = filter_metaphinder.out
                        }
            else { phabox2_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_results
} 



