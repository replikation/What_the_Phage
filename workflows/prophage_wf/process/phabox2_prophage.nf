process phabox2_prophage {
        publishDir "${params.output}/${name}/prophage/phabox2", mode: 'copy'
        publishDir "${params.output}/${name}/raw_data/", mode: 'copy', pattern: "${name}_phabox2_prophage_output.tar.gz"
        //errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:   
        tuple val(name), path("${name}_contamination_prediction_phabox2.tsv"), path("${name}_candidate_provirus_phabox2.tsv"), emit: phabox2_prophage_ch, optional: true
        tuple val(name), path("${name}_proviruses_phabox2.fa"), emit: phabox2_extracted_prophage_ch, optional: true
    script:
        """
        # activate conda environment
        source /opt/conda/etc/profile.d/conda.sh
        conda activate phabox2

        phabox2 --task contamination --dbdir /phabox_db_v2_1/ --outpth ${name}_results_prophage_contamination --contigs ${fasta} 
        
        ## get results
        cp ${name}_results_prophage_contamination/final_prediction/contamination_prediction.tsv .
        mv contamination_prediction.tsv ${name}_contamination_prediction_phabox2.tsv
       
        ## get detailed results
        cp ${name}_results_prophage_contamination/final_prediction/contamination_supplementary/candidate_provirus.tsv .
        mv candidate_provirus.tsv ${name}_candidate_provirus_phabox2.tsv

        # get provirus fasta
        cp ${name}_results_prophage_contamination/final_prediction/contamination_supplementary/proviruses.fa .
        mv proviruses.fa ${name}_proviruses_phabox2.fa

        # zip for export
        tar -czf ${name}_phabox2_prophage_output.tar.gz ${name}_results_prophage_contamination


        """

    stub:
        """
        touch ${name}_proviruses.fa
        touch ${name}_contamination_prediction.tsv
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
