include { sourmash_for_tax } from './process/phage_tax_classification/sourmash_for_tax'
include { download_references } from './process/phage_tax_classification/download_references'
include { sourmash_download_DB } from './process/phage_tax_classification/sourmash_download_DB'
include { split_multi_fasta_2 } from './process/phage_tax_classification/split_multi_fasta'

workflow phage_tax_classification_wf {
    take:   fasta_and_tool_results
    main:    
            fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}
            // get refs
            download_references()
            // sourmash db build    
            sourmash_download_DB(download_references.out)

            sourmash_for_tax(split_multi_fasta_2(fasta), sourmash_download_DB.out).groupTuple(remainder: true)
            
    emit:   sourmash_for_tax.out
}