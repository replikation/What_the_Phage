process r_plot_reads {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
      label 'ggplot'
    input:
      tuple val(name), file(results)
    output:
      tuple val(name), file("phage-distribution.pdf")
    shell:
      """
      #!/usr/bin/Rscript

      library(ggplot2)
      
      inputdata <- read.table("${results}", header = TRUE, sep = ";")
      
      pdf("phage-distribution.pdf", height = 6, width = 10)
        ggplot(data=inputdata, aes(x=type, y=amount)) +
        geom_bar(stat="identity") +
        theme(legend.position = "none") +
        coord_flip()
      dev.off()
      """
}