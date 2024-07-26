process pharokka {
    publishDir "${params.output}/${name}/pharokka", mode: 'copy'
    label 'pharokka'
    input:
        tuple val(name), path(fasta)
    output: 
        path("*_pharokka_out"), emit: pharokka_folder_ch optional true
    script:
        """

        pharokka.py -i ${fasta} -o ${name}_pharokka_out -t 10 -d /pharokka_v1.4.0_databases -f -p ${name}

        """
      stub:
        """
        mkdir stub_pharokka_out

        """
}


process pharokka_plotter {
    publishDir "${params.output}/${name}/pharokka", mode: 'copy'
    label 'pharokka'
    input:
        tuple val(name), path(fasta)
        path(pharokka_annotation_out)
        tuple val(sec_name), path(checkv_results)
    output: 
         tuple val(name), path("pharokka_plots"), emit: annotation_map_ch optional true
    script:
        """

        ## split fasta to single contigs needed
        ## LC_ALL=C allow awk to use float numbers
        LC_ALL=C awk '{if(\$9>75.00)print\$1}' < ${checkv_results} |tail -n+2 > tmp_contigs_to_plot.tsv

        ## extract contigs based on list
        mkdir fastas_to_plot
        mkdir fastas_to_plot/sub
        awk -F'>' 'NR==FNR{ids[\$0]; next} NF>1{f=(\$2 in ids)} f' tmp_contigs_to_plot.tsv ${fasta} > fastas_to_plot/sub/tmp_contigs_to_plot.fasta
        
        ## split fasta into several files
        cd fastas_to_plot/ && awk -F "|" '/^>/ {close(F); ID=\$1; gsub("^>", "", ID); F=ID".fasta"} {print >> F}' sub/tmp_contigs_to_plot.fasta && cd ..

        for i in fastas_to_plot/*.fasta; do
            contig_name=\$(echo \$i |cut -d"/" -f2 |cut -d"." -f1)
            pharokka_multiplotter.py -g ${pharokka_annotation_out}/.gbk  -o pharokka_plots


            pharokka_plotter.py -i \$i -n "\$contig_name"_annotation_map -o ${pharokka_annotation_out} --interval 8000 --annotations 0.5 --plot_title "\$contig_name" -p ${name} -f
            ## mv ${pharokka_annotation_out}/_annotation_map.png "\$contig_name"_annotation_map.png
            ## mv ${pharokka_annotation_out}/_annotation_map.svg "\$contig_name"_annotation_map.svg
            mv ${pharokka_annotation_out}/*_annotation_map.png .
            mv ${pharokka_annotation_out}/*_annotation_map.svg .
        done

        
        """
      stub:
        """
        touch stub.svg
        touch stub.png
        """
}

// pharokka_plotter.py -i all_pos_phage_filtered.fa -n all_pos_phage_annotation_map -o all_pos_phage_pharokka_out --interval 8000 --annotations 0.5 --plot_title 'test_Phage' -p all_pos_phage
// split fasta and keep contigname as a file name:awk 'BEGIN{RS=">";FS="\n"} NR>1{fnme=$1".fasta"; print ">" $0 > fnme; close(fnme);}' example.fasta

//
LOCUS       pos_phage_9           221908 bp    DNA     linear   PHG 25-JUL-2024
DEFINITION  pos_phage_9.
ACCESSION   pos_phage_9
VERSION     pos_phage_9
KEYWORDS    .
SOURCE      .
  ORGANISM  .
            .
FEATURES             Location/Qualifiers
     CDS             1..753
                     /ID="EPQHBJFJ_CDS_0949"
                     /transl_table=11
                     /phrog="246"
                     /top_hit="p216000 VI_03943"
                     /locus_tag="EPQHBJFJ_CDS_0949"
                     /function="other"
                     /product="NinI-like serine-threonine phosphatase"
                     /source="PHANOTATE_1.5.1"
                     /score="-139481.4743619502"
                     /phase="0"
                     /translation="MNKRLLVISDIHGEYDMFVRLLDKVKYNPQTCQLMLLGDFVDKGP
                     KSREVIELVMKLVAGGAKASLGNHELSFLRWLQGDRSRFHSSTSSTFRSYVYTSGNARR
                     KYTRFELDEGRRYILKRYKHHVNFLKSLPYYFEDDEHVYVHAGFDSSSDDWRKNTKTDD
                     FVWIRERFYNNPTNEEKITVFGHTKCRRLHDSDDPWFDGDKIGIDGGASEQGQLNCLEI
                     LGNKEYRIHKVFARNVRGGNQTYGKQAM"
ORIGIN
        1 atgaataagc gattattagt aatatcggac atacacggag agtacgatat gttcgttagg
       61 ttattagata aagtaaagta taatccccaa acttgccaac taatgttact cggtgacttc
      121 gtggataaag gtccaaagtc acgtgaggta atcgagcttg tgatgaagtt agtcgctggt
      181 ggtgcaaaag cgtcacttgg taatcacgag ttgtcgttct tacgttggtt gcaaggcgat
      241 cgatcccgat tccattccag tacatcttca acctttagga gttatgttta cacttcaggt
      301 aacgctagac gtaagtacac tcggtttgaa ttagatgagg gtagacgtta tatacttaag
      361 cgttataagc atcatgtcaa tttcttaaag tcattgcctt attactttga agacgatgag
      421 catgtatacg ttcatgctgg attcgattca tcatccgacg actggagaaa gaacacgaag
      481 acggatgact tcgtatggat tagagaacgt ttttataaca atccaactaa tgaagaaaag
//