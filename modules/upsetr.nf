process upsetr_plot {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "upsetr.svg"
      label 'upsetr'
    input:
      tuple val(name), file(files)
      file(script)
    output:
      tuple val(name), file("upsetr.svg")
    script:
      """
      # simplify toolnames for R (its a quick fix for now)
        for x in *.txt; do
          filename_simple=\$(echo "\${x}" | cut -f 1 -d "_")
          mv \${x} \${filename_simple}.txt
        done
        
        Rscript ${script}
      """
}