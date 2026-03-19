process iphop {
        publishDir "${params.output}/${name}/prophage/genomad", mode: 'copy'
        // errorStrategy 'ignore'
        label 'iphop'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("${name}_filtered_find_proviruses/"), emit: iphop_prophage_ch, optional: true

    script:
        """

        # run iphop to detect potential proviruses
        # get version
        iphop_db_ver= \$(ls ${database} | grep "pub_rw")

        iphop predict --fa_file ${fasta} --db_dir ${database}/\${iphop_db_ver} --out_dir ${name}_iphop_output
    
        # reduce footprint
        rm -r ${database}


        """
    stub:
        """
        touch ${name}_filtered_ taxonomy_genomad_\${PWD##*/}.tsv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad  multifractal/genomad:v1.11.1
