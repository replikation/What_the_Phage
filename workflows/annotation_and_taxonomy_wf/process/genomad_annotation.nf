process genomad_annotation {
        publishDir "${params.output}/${name}/annotation_results/genomad/", mode: 'copy'
        // errorStrategy 'ignore'
        label 'genomad'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("*_filtered_genes.tsv"), val("genomad"), emit: genomad_annotation_ch optional true
        tuple val(name), path("*_filtered_taxonomy.tsv"), val("genomad"), emit: genomad_taxonomy_ch optional true
    script:
        """
        source /opt/conda/etc/profile.d/conda.sh
        conda activate genomad

        # extract db
        tar -xvzf ${database}

        # genomad command
        genomad annotate ${fasta} ${name}_genomad_output genomad_db

        ## for gene annotation
        mv ${name}_genomad_output/${name}_filtered_annotate/${name}_filtered_genes.tsv .

        ## for taxonomy
        mv ${name}_genomad_output/${name}_filtered_annotate/${name}_filtered_taxonomy.tsv .
        
        # reduce footprint
        rm -r genomad_db


        """
    stub:
        """
        touch ${name}_gene_annotation_\${PWD##*/}.tsv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad
