process hmmscan {
        publishDir "${params.output}/${name}/raw_data/hmm/", mode: 'copy'
        label 'hmmscan'
    input:
        tuple val(name), path(faa) 
        path(pvog_db)
    output:
        tuple val(name), path("${name}_${pvog_db}_hmmscan.tbl"), path(faa) 
    script:
        """
        hmmscan --cpu ${task.cpus} ${params.hmm_params} --noali --domtblout ${name}_${pvog_db}_hmmscan.tbl ${pvog_db}/${pvog_db}.hmm ${faa}
        """
}


// hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${vog_db}_hmmscan.tbl ${vog_db}/${vog_db}.hmm ${faa}
//      hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${rvdb_db}_hmmscan.tbl ${rvdb_db}/${rvdb_db}.hmm ${faa}