process r_plot {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
      label 'r_plot'
    input:
      set val(name), file(one), file(two), file(three), file(four), file(five), file(six) 
    output:
      set val(name), file("phage-distribution.pdf")
    script:
      """
      convert.sh
      heatmap.R summary.csv
      """
}