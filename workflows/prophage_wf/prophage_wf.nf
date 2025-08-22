include { phabox2 } from './process/phabox2/phabox2'

// change to prophage

workflow phabox_wf {
    take:   fasta
            checkV completenes and likelyhood  threshold
    main:   if (!params.pb) { 
                        
                        
                        phabox2(fasta )

                        }
                        filter_phabox2(metaphinder.out[0].groupTuple(remainder: true))
                        // raw data collector
                        // metaphinder_collect_data(metaphinder.out[1].groupTuple(remainder: true))
                        // result channel
                        // metaphinder_results = filter_metaphinder.out
                        }
            else { phabox2_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   metaphinder_results
} 
