process hmmscan {
      publishDir "${params.output}/${name}/hmm/", mode: 'copy'
      label 'hmmscan'

    input:
      tuple val(name), file(faa) 
      file(pvog_db)
      file(vog_db)
      file(rvdb_db)
    
    output:
      tuple val(name), file("${name}_${pvog_db}_hmmscan.tbl"), file(faa)
      tuple val(name), file("${name}_${vog_db}_hmmscan.tbl"), file(faa)
      tuple val(name), file("${name}_${rvdb_db}_hmmscan.tbl"), file(faa)
    
    script:
    """
      hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${pvog_db}_hmmscan.tbl ${pvog_db}/${pvog_db}.hmm ${faa}
      hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${vog_db}_hmmscan.tbl ${vog_db}/${vog_db}.hmm ${faa}
      hmmscan --cpu ${task.cpus} --noali --domtblout ${name}_${rvdb_db}_hmmscan.tbl ${rvdb_db}/${rvdb_db}.hmm ${faa}
    """
}