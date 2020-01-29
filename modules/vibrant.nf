process vibrant {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "VIBRANT*"
      label 'vibrant'
    input:
      tuple val(name), file(fasta) 
      file(database) 
    output:
      file("VIBRANT*")
    script:
      """
      rnd=${Math.random()}
      tar xzf ${database}
      mv databases/* /opt/conda/share/vibrant-1.0.1/databases/

      VIBRANT_run.py -i ${fasta} 
      
      
      """
}

//virsorter_\${rnd//0.}.list