process genomad_taxonomy {
        publishDir "${params.output}/${name}/annotation_results/genomad/", mode: 'copy', pattern: "${name}_*.tsv"
        publishDir "${params.output}/${name}/raw_data/", mode: 'copy', pattern: "${name}_genomad_taxonomy_output.tar.gz"
        errorStrategy 'ignore'
        label 'genomad'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("*_filtered_taxonomy_genomad.tsv"), emit: genomad_taxonomy_ch, optional: true
    script:
        """
        source /opt/conda/etc/profile.d/conda.sh
        conda activate genomad

        # extract db
        tar -xvzf ${database}

        # genomad command
        genomad annotate ${fasta} ${name}_genomad_output genomad_db


        ## for taxonomy
        cp ${name}_genomad_output/${name}_filtered_annotate/${name}_filtered_taxonomy.tsv .
        mv ${name}_filtered_taxonomy.tsv ${name}_filtered_taxonomy_genomad.tsv
        
        # zip for export
        tar -czf ${name}_genomad_taxonomy_output.tar.gz ${name}_genomad_output


        # reduce footprint
        rm -r genomad_db


        """
    stub:
        """
        touch ${name}_filtered_taxonomy_genomad.tsv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad
