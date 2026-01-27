include { phabox2_prophage } from './process/phabox2_prophage'
include { download_genomad_DB } from './process/download_prophage_genomad_DB'
include { genomad_prophage } from './process/genomad_prophage'
include { virsorter2_prophage } from './process/virsorter2_prophage'
include { virsorter2_download_DB } from './process/virsorter2_download_DB'
include { phigaro_prophage } from './process/phigaro_prophage'



// change to prophage

workflow prophage_wf {
    take:   fasta
    main:   

            //genomad prophage-detection
            download_genomad_DB()
            genomad_prophage(fasta, download_genomad_DB.out) // output: tuple val(name), path("${name}_filtered_find_proviruses/"): tuple val(name), path("${name}_filtered_provirus.fna")

            // phabox2 prophage-detection 
            phabox2_prophage(fasta) // output: tuple val(name), path("${name}_contamination_prediction.tsv"), path("${name}_proviruses.fa") : tuple val(name), path("${name}_proviruses.fa")
            

            // virsorter2 prophage-detection
            virsorter2_download_DB()
            virsorter2_prophage(fasta, virsorter2_download_DB.out)
            // phigalo prophage-detection
            phigaro_prophage(fasta)
            

      
                       


            
    emit:   
            prophage_report_input = genomad_prophage.out.genomad_extracted_prophage_ch
                .join(phabox2_prophage.out.phabox2_prophage_ch)
                .join(virsorter2_prophage.out[0])
                .join(phigaro_prophage.out[0])
} 
