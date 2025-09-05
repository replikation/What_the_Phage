process phabox2_annotation_plot {
        publishDir "${params.output}/${name}/annotation_results/phabox2/plots", mode: 'copy' , pattern: "*.png"
        // errorStrategy 'ignore'
        label 'r_circlize'
    input:
        tuple val(name), path(fasta)
        tuple val(name), path(annotation_file)
        tuple val(name_checkv), path(checkv_results)
    output:
        tuple val(name), path("*.png"), emit: phabox2_plots_ch 
    script:
        """
        ## 1. get high quality contigs to plot

        ## split fasta to single contigs needed
        ## LC_ALL=C allow awk to use float numbers
        LC_ALL=C awk '{if(\$9>${params.plot_completeness} && \$2>5000)print\$1}' < ${checkv_results} |tail -n+2 > tmp_contigs_to_plot_${name}.tsv
        
        

        ## 2. split fasta 

        mkdir contigs_to_plot
        ## Define input files
        FASTA="${fasta}"
        LIST="tmp_contigs_to_plot_${name}.tsv"

        ## Loop through each contig name
        while read -r contig; do

            contig_name=\$(echo "\$contig")

            # Extract the contig using awk
            awk -v id="\$contig" '
                BEGIN {RS=">"; FS="\\n"}
                \$1 == id {
                    print ">"\$0
                }
            ' "\$FASTA" > "contigs_to_plot/\${contig_name}.fasta"
        done < "\$LIST"

        ## 3. get fasta 

        for i in contigs_to_plot/*.fasta; do
            phage_cyrclize.R  "\$i" ${annotation_file}
            # R phage_cyrclize.R  "\$i" ${annotation_file}
        done

        """
    stub:
        """
        touch ${name}_gene_annotation_\${PWD##*/}.tsv
        """
}

// root@bcf3d50100e5:/# head phabox2_annotation/final_prediction/phavip_supplementary/gene_annotation.tsv 
// Genome	ORF	Start	End	Strand	GC	Annotation	pident	coverage
// pos.phage.0	pos.phage.0_1	265	537	1	0.403	hypothetical protein	96.70	1.00
// pos.phage.0	pos.phage.0_2	624	986	1	0.43	membrane protein	99.20	1.00
// pos.phage.0	pos.phage.0_3	1214	1474	1	0.421	hypothetical protein	100.00	1.00
// pos.phage.0	pos.phage.0_4	1476	2030	1	0.472	hypothetical protein	100.00	1.00
// pos.phage.0	pos.phage.0_5	2177	2542	1	0.396	hypothetical protein	100.00	1.00
// pos.phage.0	pos.phage.0_6	2844	3140	1	0.38	hypothetical protein	98.00	1.00
// pos.phage.0	pos.phage.0_7	3546	3761	1	0.324	hypothetical protein	100.00	1.00
// pos.phage.0	pos.phage.0_8	3852	4022	1	0.474	hypothetical protein	100.00	1.00
// pos.phage.0	pos.phage.0_9	4109	4468	1	0.328	hypothetical protein	98.30	1.00
