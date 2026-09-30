// Annotation
include { pvog_DB; vogtable_DB } from './process/download_pvog_DB'
include { prodigal } from './process/prodigal'
include { hmmscan } from './process/hmmscan'
include { pharokka } from './process/pharokka'
include { phabox2_annotation } from './process/phabox2_annotation'
include { download_genomad_DB } from './process/download_genomad_DB'
include { genomad_annotation } from './process/genomad_annotation'
include { compare_annotation } from './process/compare_annotation'
include { annotation_tables_summary_report } from './process/annotation_tables_summary_report'
include { filter_completeness } from './process/filter_completeness'



workflow annotation_wf {
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

                // Filter input contigs by CheckV completeness
                filtered_fasta = filter_completeness(fasta.join(checkv)).filtered_fasta_ch
                filter_too_strict = filter_completeness.out.filter_too_strict_ch

                // prodigal-pvog annotation 
                prodigal(filtered_fasta)
                prodigal_out = prodigal.out
                if (!params.annotation_db) {hmmscan(prodigal.out, pvog_DB.out)}
                else {hmmscan(prodigal.out, annotation_custom_db_ch)}         
                
                hmm_out = hmmscan.out
                


                // pharokka annotation via 
                if (!params.pharokka) {pharokka(filtered_fasta)}
                pharokka_out = pharokka.out.pharokka_gff_ch
                
                // phabox2 annotation 
                phabox2_annotation(filtered_fasta)
                phabox2_annotation_out = phabox2_annotation.out.phabox2_annotation_ch
               

                //genomad annotation
                download_genomad_DB()
                genomad_annotation(filtered_fasta, download_genomad_DB.out)
                genomad_annotation_out = genomad_annotation.out.genomad_annotation_ch

                collect_annotation_ch = pharokka.out.pharokka_gff_ch
                                         .mix( phabox2_annotation.out.phabox2_annotation_ch)
                                         .mix( genomad_annotation.out.genomad_annotation_ch)
                                         .groupTuple()


                // compare annotation tools
                // prepare annotation files for markdown report
                compare_annotation(collect_annotation_ch)
                compare_out = compare_annotation.out.bedfile_ch
                annotation_tables_summary_report(compare_annotation.out.bedfile_ch)    
                annotation_tables_out = annotation_tables_summary_report.out

    emit:
        annotation_report_input = annotation_tables_summary_report.out
        annotation_filter_too_strict = filter_too_strict
        annotation_hmm = hmm_out
        annotation_prodigal = prodigal_out
        annotation_pharokka = pharokka_out
        annotation_phabox2 = phabox2_annotation_out
        annotation_genomad = genomad_annotation_out
        annotation_compare = compare_out
        annotation_tables = annotation_tables_out
                

}

// 	Genome	Realm	Kingdom	Phylum	Class	Order	Family	Subfamily	Genus	Species	Full_taxonomy	Message
// 0	pos.phage.1	Duplodnaviria	Heunggongvirae	Uroviricota	Caudoviricetes	Not Defined Yet	Not Defined Yet	Not Defined Yet	Kelleziovirus	Kelleziovirus kellezzio	r__Duplodnaviria;k__Heunggongvirae;p__Uroviricota;c__Caudoviricetes;o__Not Defined Yet;f__Not Defined Yet;sf__Not Defined Yet;g__Kelleziovirus;s__Kelleziovirus kellezzio	Current ICTV taxonomy and the clustering on genomic similarity algorithm output appear to be consistent at the genus level
