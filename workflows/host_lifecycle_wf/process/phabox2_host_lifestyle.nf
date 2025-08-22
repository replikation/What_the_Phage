process phabox2_host_and_lifestyle {
        publishDir "${params.output}/${name}/phabox2/host_and_lifestyle/", mode: 'copy' , pattern: "*.tsv"
        errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        
        tuple val(name), path("${name}_results_host_and_lifestyle*/"), emit: phabox2_host_and_lifestyle optional true
    script:
        """
        phabox2 phatyp --dbdir /phabox_db_v2_1/ --outpth ${name}_results_host_and_lifestyle_\${PWD##*/}/ --contigs ${fasta}
        """
    stub:
        """
        
        """
}