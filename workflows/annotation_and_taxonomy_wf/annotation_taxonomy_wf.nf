// Annotation
include { pvog_DB; vogtable_DB } from './process/download_pvog_DB'
include { prodigal } from './process/prodigal'
include { hmmscan } from './process/hmmscan'
include { chromomap_parser } from './process/chromomap_parser'
include { chromomap } from './process/chromomap'
include { pharokka } from './process/pharokka'
include { pharokka_plotter } from './process/pharokka'
include { phabox2_annotation } from './process/phabox2_annotation'
include { phabox2_annotation_plot } from './process/phabox2_annotation_plot'
include { download_genomad_DB } from './process/download_genomad_DB'
include { genomad_annotation } from './process/genomad_annotation'

// Taxonomy
include { sourmash_tax } from './process/sourmash_tax'
include { split_multi_fasta_2 } from './process/split_multi_fasta'
include { download_references_NCBI } from './process/download_tax_references'
include { download_references_phage_scope } from './process/download_tax_references'
include { sourmash_NCBI_tax_build } from './process/sourmash_tax_build_DB'
include { sourmash_phage_scope_tax_build } from './process/sourmash_tax_build_DB'



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
                chromomap(chromomap_parser.out[0].mix(chromomap_parser.out[1]))

                annotationtable_markdown_input = chromomap_parser.out.annotationfile_combined_ch

                // pharokka annotation via 
                if (params.pharokka) {pharokka(fasta) 
                                        plot_in= fasta
                                        .join( pharokka.out)
                                        .join( checkv) 
                                        pharokka_plotter(plot_in)
                                }
                
                // phabox2 annotation 
                phabox2_annotation(fasta)
                phabox2_annotation_plot(fasta, phabox2_annotation.out, checkv)

                //genomad annotation
                download_genomad_DB()
                genomad_annotation(fasta, download_genomad_DB.out)

            
                ///////////////////////////////////////////////////////////////
                ///// Taxonomy
                ///////////////////////////////////////////////////////////////

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
                sourmash_tax_markdown_input = sourmash_tax.out
                //genomad Taxonomic classification
                // take tax from genomad annotation
                genomad_tax = genomad_annotation.out.genomad_taxonomy_ch

                // report_input_ch=  sourmash_tax.out.join(genomad_tax.out) 
                // report_input_ch.view()

                annotation_taxonomy_markdown_input = annotationtable_markdown_input.join(sourmash_tax_markdown_input).join(genomad_annotation.out).join(genomad_tax)

    emit:       annotation_taxonomy_markdown_input
                

}

