process phabox2_taxonomy {
        //errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        tuple val(name), path("${name}_phagcn_prediction_taxonomy_Phabox2.tsv"), emit: phabox2_taxonomy_ch, optional: true
    script:
        """

        # activate conda environment
        source /opt/conda/etc/profile.d/conda.sh
        conda activate phabox2

        # annotation
        phabox2 --task phagcn --dbdir /phabox_db_v2_1/ --outpth ${name}_Phabox2_results_taxonomy --contigs ${fasta} 

        cp ${name}_Phabox2_results_taxonomy/final_prediction/phagcn_prediction.tsv .
        mv phagcn_prediction.tsv ${name}_phagcn_prediction_taxonomy_Phabox2.tsv  

        # zip for export
        tar -czf ${name}_Phabox2_results_taxonomy.tar.gz ${name}_Phabox2_results_taxonomy


        """
    stub:
        """
        touch ${name}_phagcn_prediction_taxonomy_Phabox2.tsv  
        """
}


