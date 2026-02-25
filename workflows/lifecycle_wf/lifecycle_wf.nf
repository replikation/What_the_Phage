include { phabox2_lifecycle } from './process/phabox2_lifecycle'


workflow lifecycle_wf {
    take:   fasta
    
    main: 

            phabox2_lifecycle(fasta)  







    
    emit: lifecycle_results = phabox2_lifecycle.out
    //host: https://www.biorxiv.org/content/10.1101/2020.12.06.413476v1
}

