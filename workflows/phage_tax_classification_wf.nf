include { sourmash_for_tax } from './process/phage_tax_classification/sourmash_for_tax'
include { sourmash_database } from './process/phage_tax_classification/sourmash_database_download_DB'
include { split_multi_fasta_2 } from './process/phage_tax_classification/split_multi_fasta'

workflow phage_tax_classification {
    take:   fasta
    main:    
            sourmash_for_tax(split_multi_fasta_2(fasta), sourmash_database()).groupTuple(remainder: true)
    emit:   sourmash_for_tax.out
}