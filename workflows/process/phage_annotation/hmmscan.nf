process hmmscan {
        publishDir "${params.output}/${name}/raw_data/hmm/", mode: 'copy'
        label 'hmmscan'
    input:
        tuple val(name), path(faa) 
        path(annotation_db)
    output:
        tuple val(name), path("${name}_${annotation_db}_hmmscan.tbl"), path(faa) 
    script:
        if (!params.annotation_db)
        """
        hmmscan --cpu ${task.cpus} ${params.hmm_params} --noali --domtblout ${name}_${annotation_db}_hmmscan.tbl ${annotation_db}/${annotation_db}.hmm ${faa}
        """
        else
        """
        mkdir custom_annotation_db
        tar -xvzf ${annotation_db} -C custom_annotation_db
        hmmscan --cpu ${task.cpus} ${params.hmm_params} --noali --domtblout ${name}_${annotation_db}_hmmscan.tbl custom_annotation_db/*.hmm ${faa}
        """

    stub:
        """
        touch ${name}_${annotation_db}_hmmscan.tbl
        """
}


// hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${vog_db}_hmmscan.tbl ${vog_db}/${vog_db}.hmm ${faa}
//      hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${rvdb_db}_hmmscan.tbl ${rvdb_db}/${rvdb_db}.hmm ${faa}