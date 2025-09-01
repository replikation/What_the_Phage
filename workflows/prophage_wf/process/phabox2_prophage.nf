process phabox2_prophage {
        publishDir "${params.output}/${name}/phabox2/prophage/", mode: 'copy' , pattern: "*.tsv"
        errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        
        tuple val(name), path("${name}_contamination_prediction_*.tsv"), emit: phabox2_host_and_lifestyle optional true
    script:
        """
        phabox2 contamination --dbdir /phabox_db_v2_1/ --outpth ${name}_results_prophage_contamination --contigs ${fasta} --threads 
        
        mv ${name}_results_prophage_contamination/final_prediction/contamination_prediction.tsv ${name}_results_prophage_contamination/final_prediction/${name}_contamination_prediction_\${PWD##*/}.tsv
        mv ${name}_results_prophage_contamination/final_prediction/${name}_contamination_prediction_\${PWD##*/}.tsv .
        
        """

    stub:
        """
        touch ${name}_contamination_prediction_\${PWD##*/}.tsv
        """
}


// Accession	Length	Total_genes	Viral_genes	Prokaryotic_genes	Kmer_freq	Contamination	Provirus	Pure_viral
// pos.phage.0	146647	230	120	3	1.0	0	No	High quality
// pos.phage.1	58871	97	18	1	1.0	0	No	High quality
// pos.phage.2	58560	95	16	1	1.0	0	No	High quality
// pos.phage.3	59443	90	46	1	1.0	0	No	High quality
// pos.phage.4	51290	74	38	0	1.0	0	No	High quality
// pos.phage.5	43293	67	53	0	1.0	0	No	High quality
// pos.phage.6	43851	53	30	0	1.0	0	No	High quality
// pos.phage.7	44262	54	30	0	1.0	0	No	High quality
// pos.phage.8	41865	60	51	0	1.0	0	No	High quality
// pos.phage.9	221908	291	38	19	1.0	4.66	Yes	Low quality
