include { sourmash_tax } from './process/sourmash_tax'
include { split_multi_fasta_2 } from './process/split_multi_fasta'
include { download_references_NCBI } from './process/download_tax_references'
include { download_references_phage_scope } from './process/download_tax_references'
include { sourmash_NCBI_tax_build } from './process/sourmash_tax_build_DB'
include { sourmash_phage_scope_tax_build } from './process/sourmash_tax_build_DB'
include { download_genomad_DB } from './process/download_tax_genomad_DB'
include { genomad_tax } from './process/genomad_tax'

workflow phage_tax_classification_wf {
    take:   fasta_and_tool_results
    main:    
            fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}
                      
                    if (params.phage_scope_tax) {
                         download_references_phage_scope()
                         sourmash_phage_scope_tax_build(download_references_phage_scope.out.phage_ref_ch)
                         sourmash_tax_db_ch = sourmash_phage_scope_tax_build.out.phage_db_ch 
                         sourmash_tax_metadata_ch = download_references_phage_scope.out.phagescope_tax_metadata_ch
                         }

                    else {
                         download_references_NCBI()
                         sourmash_NCBI_tax_build(download_references_NCBI.out.phage_ref_ch)
                         sourmash_tax_db_ch = sourmash_NCBI_tax_build.out.phage_db_ch
                         sourmash_tax_metadata_ch = download_references_NCBI.out.ncbi_tax_metadata_ch
                         }                 
                    //else { sourmash_db_ch = Channel.empty() }

            
            sourmash_tax(split_multi_fasta_2(fasta), sourmash_tax_db_ch, sourmash_tax_metadata_ch).groupTuple(remainder: true)

            //genomad Taxonomic classification
            download_genomad_DB()
            genomad_tax(fasta, download_genomad_DB.out)

            report_input_ch=  sourmash_tax.out.join(genomad_tax.out) 
            report_input_ch.view()
            
    emit:   sourmash_tax.out
}