process r_plot {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
      label 'r_plot'
    input:
      tuple val(name), file(a), file(b), file(c), file(d), file(e), file(e)
    output:
      tuple val(name), file("phage-distribution.pdf")
    script:
      """
      convert.sh
      heatmap.R summary.csv
      """
}