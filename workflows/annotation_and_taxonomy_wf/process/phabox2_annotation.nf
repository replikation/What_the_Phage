process phabox2_annotation {
        publishDir "${params.output}/${name}/annotation_results/phabox2/", mode: 'copy' , pattern: "*.tsv"
        // errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        tuple val(name), path("${name}_gene_annotation_phabox2.tsv"), emit: phabox2_annotation_ch, optional: true
    script:
        """

        # activate conda environment
        source /opt/conda/etc/profile.d/conda.sh
        conda activate phabox2

        # annotation
        phabox2 --task phavip --dbdir /phabox_db_v2_1/ --outpth ${name}_results_annotation_ --contigs ${fasta} 

        mv ${name}_results_annotation_*/final_prediction/phavip_supplementary/gene_annotation.tsv .
        mv gene_annotation.tsv ${name}_gene_annotation_phabox2.tsv  



        """
    stub:
        """
        touch ${name}_gene_annotation_.tsv
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
