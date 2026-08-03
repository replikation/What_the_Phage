include { sourmash_tax } from './process/sourmash_tax'
include { download_genomad_DB } from './process/download_genomad_DB'
include { genomad_taxonomy } from './process/genomad_taxonomy'
include { split_multi_fasta_2 } from './process/split_multi_fasta'
include { download_references_NCBI } from './process/download_tax_references'
include { download_references_phage_scope } from './process/download_tax_references'
include { sourmash_NCBI_tax_build } from './process/sourmash_tax_build_DB'
include { sourmash_phage_scope_tax_build } from './process/sourmash_tax_build_DB'
include { taxmyphage } from './process/taxmyphage'
include { collect_taxonomy_results } from './process/collect_taxonomy_results'
include { phabox2_taxonomy } from './process/phabox2_taxonomy'



workflow taxonomy_wf {
        take:   fasta

        main:                
                
                
                // Databases for taxonomic classification
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

                // sourmash taxonomic classification
                sourmash_tax(split_multi_fasta_2(fasta), sourmash_tax_db_ch, sourmash_tax_metadata_ch)
               
                // phabox2 taxonomy
                phabox2_taxonomy(fasta)
             
                //genomad taxonomic classification
                download_genomad_DB()
                genomad_taxonomy(fasta, download_genomad_DB.out)

                // taxmyphage taxonomic classification
                taxmyphage(fasta)



                // collect the taxonomy results and prepare for report
                collect_taxonomy_results(sourmash_tax.out.join(genomad_taxonomy.out).join(phabox2_taxonomy.out).join(taxmyphage.out)) // i need to adjust the taxonomy combination script
                taxonomy_report_input = collect_taxonomy_results.out.taxonomy_combined_ch
                            .mix(sourmash_tax.out.tax_class_ch)
                            .mix(genomad_taxonomy.out.genomad_taxonomy_ch)
                            .mix(taxmyphage.out.taxmyphage_ch)
                // taxonomy_combined_ch.view()

        emit:   taxonomy_report_input = taxonomy_report_input

}