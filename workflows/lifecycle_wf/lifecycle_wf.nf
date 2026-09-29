include { phabox2_lifecycle } from './process/phabox2_lifecycle'
include { bacphlip_lifecycle } from './process/bacphlip_lifecycle'
include { lifecycle_tables_summary_report } from './process/lifecycle_tables_summary_report'


workflow lifecycle_wf {
    take:   fasta
    
    main: 
phabox2_lifecycle(fasta)  
            bacphlip_lifecycle(fasta)
            lifecycle_phabox2 = phabox2_lifecycle.out
            lifecycle_bacphlip = bacphlip_lifecycle.out

            // collect results
            collect_lifecycle_ch = phabox2_lifecycle.out.mix(bacphlip_lifecycle.out).groupTuple()
            lifecycle_tables_summary_report(collect_lifecycle_ch) // i need to adjust the lifecycle combination script when i have a new lifecycle tool

    
    emit:
        lifecycle_results = lifecycle_tables_summary_report.out
        lifecycle_phabox2_ch = lifecycle_phabox2
        lifecycle_bacphlip_ch = lifecycle_bacphlip

}