process r_plot {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
      label 'r_plot'
    input:
      tuple val(name), file(files)
    output:
      tuple val(name), file("phage-distribution.pdf")
    script:
      """
      # simplify toolnames for R (its a quick fix for now)
        for x in *.txt; do
          filename_simple=\$(echo "\${x}" | cut -f 1 -d "_")
          mv \${x} \${filename_simple}.txt
        done
      # parser script in xargs
        convert.sh
      # plotting
        heatmap.R summary.csv
      """
}