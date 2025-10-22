process genomad_host_prediction {
        publishDir "${params.output}/${name}/prophage/genomad", mode: 'copy'
        // errorStrategy 'ignore'
        label 'genomad'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("${name}_filtered_find_proviruses/"), emit: genomad_prophage_ch, optional: true
        tuple val(name), path("${name}_filtered_provirus.fna"), emit: genomad_extracted_prophage_ch, optional: true
    script:
        """
        source /opt/conda/etc/profile.d/conda.sh
        conda activate genomad

        # extract db
        tar -xvzf ${database}


        # run genomad annotate to detect potential proviruses
        genomad annotate ${fasta} ${name}_genomad_output genomad_db


        # genomad provirus command
        genomad find-proviruses ${fasta} ${name}_genomad_output genomad_db
        
        mv ${name}_genomad_output/${name}_filtered_find_proviruses/${name}_filtered_provirus.fna .
        mv ${name}_genomad_output/${name}_filtered_find_proviruses/ .



        # reduce footprint
        rm -r genomad_db


        """
    stub:
        """
        touch ${name}_filtered_taxonomy_genomad_\${PWD##*/}.tsv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad  multifractal/genomad:v1.11.1
