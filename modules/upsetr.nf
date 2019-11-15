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
        Rscript ${script}
      """
}