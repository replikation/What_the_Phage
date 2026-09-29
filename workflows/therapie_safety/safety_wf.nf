include { abricate } from './process/abricate'

workflow safety_wf {
    take:   fasta
    main:   

            abricate(fasta)
    
    emit:
        safety_results
        safety_abricate = abricate.out.abricate_safety
}   