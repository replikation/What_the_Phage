process r_plot {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
      label 'r_plot'
    input:
      tuple val(name), file(files)
    output:
      tuple val(name), file("phage-distribution.pdf")
    script:
      """
      # parser script in xargs
        convert.sh
      # plotting
        heatmap.R summary.csv
      """
}