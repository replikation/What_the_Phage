include { virnet } from './process/virnet/virnet'
include { filter_virnet } from './process/virnet/filter_virnet'
include { virnet_collect_data } from './process/virnet/virnet_collect_data'
include { normalize_contig_size } from './process/virnet/normalize_contig_size'


workflow virnet_wf {
    take:   fasta

    main:   if (!params.vn) { 
                        filter_virnet(virnet(normalize_contig_size(fasta)).groupTuple(remainder: true))
                        // raw data collector
                        virnet_collect_data(virnet.out.groupTuple(remainder: true))
                        // result channel
                        virnet_results = filter_virnet.out
                        }
            else { virnet_results = Channel.from( [ 'deactivated', 'deactivated'] ) }
    emit:   virnet_results
} 