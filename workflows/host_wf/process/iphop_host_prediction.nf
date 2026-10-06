process iphop_host_prediction {
        //errorStrategy 'ignore'
        label 'iphop'
    input:
        tuple val(name), path(fasta)
        path(database)
    output:
        tuple val(name), path("${name}_iphop_output"), emit: iphop_Host_folder_ch, optional: true
        tuple val(name), path("${name}_Host_prediction_to_genus_m90.csv"), emit: iphop_host_genus_ch, optional: true

    script:
        """
        # run iphop to detect potential proviruses
        # get version
        iphop_db_ver=\$(ls ${database}/ | grep "pub_rw")
        chmod -R 777 ${database}/\$iphop_db_ver

        iphop predict --fa_file ${fasta} --db_dir ${database}/\$iphop_db_ver --out_dir ${name}_iphop_output -t ${task.cpus}

        mv ${name}_iphop_output/Host_prediction_to_genome_m90.csv ${name}_iphop_output/${name}_Host_prediction_to_genome_m90.csv || true
        mv ${name}_iphop_output/Host_prediction_to_genus_m90.csv ${name}_iphop_output/${name}_Host_prediction_to_genus_m90.csv || true
        mv ${name}_iphop_output/Detailed_output_by_tool.csv ${name}_iphop_output/${name}_Detailed_output_by_tool.csv || true

        cp ${name}_iphop_output/${name}_Host_prediction_to_genus_m90.csv .

        # reduce footprint
        rm -r ${database}


        """
    stub:
        """
        mkdir -p ${name}_iphop_output
        touch ${name}_Host_prediction_to_genus_m90.csv
        """
}

// to run the docker:  docker run --rm -it --entrypoint /bin/bash -u root -v $PWD:/input antoniopcamargo/genomad  multifractal/genomad:v1.11.1
