process phabox2_identify {
        publishDir "${params.output}/${name}/phabox2/", mode: 'copy' , pattern: "*.tsv"
        // errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        tuple val(name), path("${name}_phamer_prediction_*.tsv"), emit: phabox2_results_ch optional true
        tuple val(name), path("${name}_results_identify/"), emit: phabox2_collect_raw_ch optional true
    script:
        """
        ## activate conda environment
        source /opt/conda/etc/profile.d/conda.sh
        conda activate phabox2
        
        ## phabox2 -h
        phabox2 --task phamer --dbdir /phabox_db_v2_1/ --outpth ${name}_results_identify_\${PWD##*/}/ --contigs ${fasta}
        mv ${name}_results_identify_*/final_prediction/phamer_prediction.tsv .
        mv phamer_prediction.tsv ${name}_phamer_prediction_\${PWD##*/}.tsv

        """
    stub:
        """
        touch ${name}_phamer_prediction_\${PWD##*/}.tsv 
        mkdir ${name}_results_identify/
        """
}
// root@bcf3d50100e5:/# cat phabox2_identify/final_prediction/phamer_prediction.tsv 
// Accession	Length	Pred	Proportion	PhaMerScore	PhaMerConfidence
// pos.phage.0	146647	virus	1.0	1.0	high-confidence
// pos.phage.1	58871	virus	1.0	1.0	high-confidence
// pos.phage.2	58560	virus	1.0	1.0	high-confidence
// pos.phage.3	59443	virus	1.0	1.0	high-confidence
// pos.phage.4	51290	virus	1.0	1.0	high-confidence
// pos.phage.5	43293	virus	1.0	1.0	high-confidence
// pos.phage.6	43851	virus	1.0	1.0	high-confidence
// pos.phage.7	44262	virus	1.0	1.0	high-confidence
// pos.phage.8	41865	virus	1.0	1.0	high-confidence
// pos.phage.9	221908	virus	1.0	1.0	high-confidence
