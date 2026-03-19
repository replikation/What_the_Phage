process genomad_annotation {
        publishDir "${params.output}/${name}/annotation_results/genomad/", mode: 'copy', pattern: "${name}_*.tsv"
        publishDir "${params.output}/${name}/raw_data/", mode: 'copy', pattern: "${name}_genomad_annotation_output.tar.gz"
        errorStrategy 'ignore'
        label 'genomad'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("*_filtered_genes_annotation_genomad.tsv"), emit: genomad_annotation_ch, optional: true
    script:
        """
        source /opt/conda/etc/profile.d/conda.sh
        conda activate genomad

        # extract db
        tar -xvzf ${database}

        # genomad command
        genomad annotate ${fasta} ${name}_genomad_output genomad_db

        ## for gene annotation
        cp ${name}_genomad_output/${name}_filtered_annotate/${name}_filtered_genes.tsv .
        mv ${name}_filtered_genes.tsv ${name}_filtered_genes_annotation_genomad.tsv
        
        # zip for export
        tar -czf ${name}_genomad_annotation_output.tar.gz ${name}_genomad_output


        # reduce footprint
        rm -r genomad_db


        """
    stub:
        """
        touch ${name}_filtered_genes_annotation_genomad.tsv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad
