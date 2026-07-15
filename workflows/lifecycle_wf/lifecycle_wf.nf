include { phabox2_lifecycle } from './process/phabox2_lifecycle'
include { bacphlip_lifecycle } from './process/bacphlip_lifecycle'


workflow lifecycle_wf {
    take:   fasta
    
    main: 

            phabox2_lifecycle(fasta)  
            bacphlip_lifecycle(fasta)






    
    emit: lifecycle_results = phabox2_lifecycle.out.join(bacphlip_lifecycle.out)
}

