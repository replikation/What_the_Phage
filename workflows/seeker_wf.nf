include { seeker } from './process/seeker/seeker'
include { filter_seeker } from './process/seeker/filter_seeker'
include { seeker_collect_data } from './process/seeker/seeker_collect_data'

workflow seeker_wf {
	take:	fasta
	main:	if (!params.sk) {
                        // run and filter seeker
                        filter_seeker(seeker(fasta).groupTuple(remainder: true))
                        // raw data collector
                        seeker_collect_data(seeker.out.groupTuple(remainder: true))
                        // results channel
                        seeker_results = filter_seeker.out		
                        }
            else { seeker_results = Channel.from( ['deactivated', 'deactivated'] ) }
    emit:   seeker_results
}
