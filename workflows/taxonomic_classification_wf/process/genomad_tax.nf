process genomad_tax {
        publishDir "${params.output}/${name}/taxonomic-classification/genomad", mode: 'copy'
        // errorStrategy 'ignore'
        label 'genomad'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("${name}_filtered_taxonomy_genomad.tsv"), emit: genomad_tax_ch optional true
    script:
        """
        source /opt/conda/etc/profile.d/conda.sh
        conda activate genomad

        # extract db
        tar -xvzf ${database}

        # genomad command
        genomad annotate ${fasta} ${name}_genomad_output genomad_db
        
        mv ${name}_genomad_output/${name}_filtered_annotate/${name}_filtered_taxonomy.tsv .
        mv ${name}_filtered_taxonomy.tsv ${name}_filtered_taxonomy_genomad.tsv


        # reduce footprint
        rm -r genomad_db


        """
    stub:
        """
        touch ${name}_filtered_taxonomy_genomad_\${PWD##*/}.tsv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad
