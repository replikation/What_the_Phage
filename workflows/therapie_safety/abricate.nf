process abricate {
    publishDir "${params.output}/${name}/safety_prediction/", mode: 'copy' , pattern: "*.tsv"
    //errorStrategy 'ignore'
    label 'abricate'
    input:
        tuple val(name), path(fasta)
        path(abricate_db)
    output:
        
        tuple val(name), path("${name}_abricate_genesofinterest.tsv"), emit: abricate_safety, optional: true
    script:
        """
        # ACTIVATE HISTORY AND PIPEFAIL
            set -o history
            set -euxo pipefail

        # EXECUTE TOOL
            ${abricate_update_cmd}
            abricate ${fasta} --nopath --quiet ${params.abricate_params} --db ${abricate_db} --threads ${task.cpus} >> ${name}_abricate_genesofinterest.tsv
        
        
        

        """
    stub:
        """
        touch ${name}_abricate_genesofinterest.tsv
        """
}