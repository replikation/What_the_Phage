include { phigaro } from './process/phigaro/phigaro'
include { phigaro_collect_data } from './process/phigaro/phigaro_collect_data'

workflow phigaro_wf {
    take:   fasta
    main:   if (!params.ph) { 
                        phigaro(fasta)
                        // raw data collector
                        phigaro_collect_data(phigaro.out[1].groupTuple(remainder: true))
                        // result channel // [0] emits filtered positive phage sequences (provided by DEV)
                        phigaro_results = phigaro.out[0]
                        }
            else { phigaro_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   phigaro_results
}