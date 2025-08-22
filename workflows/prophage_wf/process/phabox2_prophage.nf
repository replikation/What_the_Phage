process phabox2_prophage {
        publishDir "${params.output}/${name}/phabox2/prophage/", mode: 'copy' , pattern: "*.tsv"
        errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        
        tuple val(name), path("${name}_results_prophage*/"), emit: phabox2_host_and_lifestyle optional true
    script:
        """
        phabox2 contamination --dbdir /phabox_db_v2_1/ --outpth ${name}_results_prophage_\${PWD##*/}/ --contigs ${fasta} --threads 
        """

    stub:
        """
        
        """
}