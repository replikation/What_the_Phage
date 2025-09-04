process phabox2_annotation_plot {
        publishDir "${params.output}/${name}/annotation/phabox2/", mode: 'copy' , pattern: "*.tsv"
        // errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
        tuple val(name_checkv), path(checkv_results)
    output:
        tuple val(name), path("${name}_gene_annotation_*.tsv"), emit: phabox2_annotation_ch optional true
    script:
        """
        ## i could plot everything, but only put plots with > 09 completeness into the report

        # 1. get high quality contigs to plot
        ## split fasta to single contigs needed
        ## LC_ALL=C allow awk to use float numbers
        LC_ALL=C awk '{if(\$9>${params.plot_completeness} && \$2>5000)print\$1}' < ${checkv_results} |tail -n+2 > tmp_contigs_to_plot_${name}.tsv
        
        
      



        # 2. split fasta 

        mkdir ${name}_contigs/

        while read line
            do
        if [[ \${line:0:1} == '>' ]]
        then
            outfile=\${line#>}.fa
            echo "\${line}" > ${name}_contigs/\${outfile}
        else
            echo "\${line}" >> ${name}_contigs/\${outfile}
        fi
            done < ${fasta}


        3. get fasta 

        4. run Rscript to plot
        ## check if tmp file is empty
        if [ -s tmp_contigs_to_plot_${name}.tsv ]; then
            # The file is not-empty.
            ## plot
            while read LINE; do
               Plot command
            done < tmp_contigs_to_plot_${name}.tsv

        else
            # The file is empty.
            touch pharokka_plots/nothing_to_plot.txt
        fi

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
