// Annotation
include { pvog_DB; vogtable_DB } from './process/download_pvog_DB'
include { prodigal } from './process/prodigal'
include { hmmscan } from './process/hmmscan'
include { chromomap_parser } from './process/chromomap_parser'
include { pharokka } from './process/pharokka'
include { phabox2_annotation } from './process/phabox2_annotation'
include { download_genomad_DB } from './process/download_genomad_DB'
include { genomad_annotation } from './process/genomad_annotation'
include { compare_annotation } from './process/compare_annotation'
include { annotation_tables_summary_report } from './process/annotation_tables_summary_report'

// Taxonomy
include { sourmash_tax } from './process/sourmash_tax'
include { split_multi_fasta_2 } from './process/split_multi_fasta'
include { download_references_NCBI } from './process/download_tax_references'
include { download_references_phage_scope } from './process/download_tax_references'
include { sourmash_NCBI_tax_build } from './process/sourmash_tax_build_DB'
include { sourmash_phage_scope_tax_build } from './process/sourmash_tax_build_DB'
include { taxmyphage } from './process/taxmyphage'
include { collect_taxonomy_results } from './process/collect_taxonomy_results'



workflow annotation_taxonomy_wf {
        take:   fasta
                checkv
        main:
           
                ///////////////////////////////////////////////////////////////
                ///// Annotion
                ///////////////////////////////////////////////////////////////
                
                // Input for custom annotation database
                if (params.annotation_db) { annotation_custom_db_ch = Channel
                                                .fromPath( params.annotation_db, checkIfExists: true)
                                                }

                // Database for hmmscan
                pvog_DB()
                vogtable_DB()

                // prodigal-pvog annotation 
                prodigal(fasta)
                if (!params.annotation_db) {hmmscan(prodigal.out, pvog_DB.out)}
                else {hmmscan(prodigal.out, annotation_custom_db_ch)}         
                chromomap_parser(fasta.join(hmmscan.out), vogtable_DB.out)


                // pharokka annotation via 
                if (!params.pharokka) {pharokka(fasta)}
                
                // phabox2 annotation 
                phabox2_annotation(fasta)
               

                //genomad annotation
                download_genomad_DB()
                genomad_annotation(fasta, download_genomad_DB.out)

                collect_annotation_ch = chromomap_parser.out.annotationfile_combined_ch
                                         .mix( pharokka.out.pharokka_gff_ch)
                                         .mix( phabox2_annotation.out.phabox2_annotation_ch)
                                         .mix( genomad_annotation.out.genomad_annotation_ch)
                                         .groupTuple()


                // compare annotation tools
                 // prepare annotation files for markdown report
                compare_annotation(collect_annotation_ch)
                annotation_tables_summary_report(compare_annotation.out.bedfile_ch)    


                ///////////////////////////////////////////////////////////////
                ///// Taxonomy
                ///////////////////////////////////////////////////////////////


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
                
             
                //genomad Taxonomic classification
                // take tax from genomad annotation
                genomad_tax = genomad_annotation.out.genomad_taxonomy_ch


                // collect the taxonomy results and prepare for report
                collect_taxonomy_results(sourmash_tax.out.join(genomad_tax))
                taxonomy_combined_ch = collect_taxonomy_results.out.taxonomy_combined_ch
                // taxonomy_combined_ch.view()

               
    emit:       annotation_report_input = annotation_tables_summary_report.out
                taxonomy_report_input = taxonomy_combined_ch.join(sourmash_tax.out).join(genomad_tax)
                

}

// 	Genome	Realm	Kingdom	Phylum	Class	Order	Family	Subfamily	Genus	Species	Full_taxonomy	Message
// 0	pos.phage.1	Duplodnaviria	Heunggongvirae	Uroviricota	Caudoviricetes	Not Defined Yet	Not Defined Yet	Not Defined Yet	Kelleziovirus	Kelleziovirus kellezzio	r__Duplodnaviria;k__Heunggongvirae;p__Uroviricota;c__Caudoviricetes;o__Not Defined Yet;f__Not Defined Yet;sf__Not Defined Yet;g__Kelleziovirus;s__Kelleziovirus kellezzio	Current ICTV taxonomy and the clustering on genomic similarity algorithm output appear to be consistent at the genus level
