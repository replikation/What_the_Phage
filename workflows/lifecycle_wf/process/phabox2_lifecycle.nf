process phabox2_lifecycle {
        publishDir "${params.output}/${name}/host_lifecycle/phabox2", mode: 'copy' , pattern: "*.tsv"
        publishDir "${params.output}/${name}/host_lifecycle/phabox2", mode: 'copy' , pattern: "*.tar.gz"
        //errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        
        tuple val(name), path("${name}_phatyp_prediction_lifecycle_phabox2.tsv"), emit: phabox2_lifecycle, optional: true
    script:
        """

        # activate conda environment
        source /opt/conda/etc/profile.d/conda.sh
        conda activate phabox2
        
        # run phatyp
        phabox2 --task phatyp --dbdir /phabox_db_v2_1/ --outpth ${name}_results_lifecycle --contigs ${fasta}
        
        mv ${name}_results_lifecycle/final_prediction/phatyp_prediction.tsv . 
        mv phatyp_prediction.tsv ${name}_phatyp_prediction_lifecycle_phabox2.tsv


        tar -czf ${name}_results_phabox2.tar.gz ${name}_results_lifecycle
        

        """
    stub:
        """
        touch ${name}_phatyp_prediction_lifecycle_phabox2.tsv
        """
}




// phatyp 
// root@bcf3d50100e5:/# cat phabox2_host_lifecycle/final_prediction/phatyp_prediction.tsv 
// Accession	Length	TYPE	PhaTYPScore
// pos.phage.0	146647	virulent	1.0
// pos.phage.1	58871	virulent	0.99
// pos.phage.2	58560	virulent	0.56
// pos.phage.3	59443	virulent	1.0
// pos.phage.4	51290	virulent	1.0
// pos.phage.5	43293	temperate	1.0
// pos.phage.6	43851	virulent	1.0
// pos.phage.7	44262	virulent	1.0
// pos.phage.8	41865	virulent	1.0
// pos.phage.9	221908	virulent	1.0
