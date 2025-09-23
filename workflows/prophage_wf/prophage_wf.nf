include { phabox2_prophage } from './process/phabox2_prophage'
include { download_genomad_DB } from './process/download_prophage_genomad_DB'
include { genomad_prophage } from './process/genomad_prophage'


// change to prophage

workflow prophage_wf {
    take:   fasta
    main:   


            // phabox2 prophage-detection 
            //phabox2_annotation(fasta)
            //phabox2_annotation_plot(fasta, phabox2_annotation.out, checkv)

            //genomad prophage-detection
            download_genomad_DB()
            genomad_prophage(fasta, download_genomad_DB.out)

            //virsorter2_prophage
            //phigaro(fasta)
            

                        


            
    emit:   metaphinder_results
} 
