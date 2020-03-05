process chromomap {
      publishDir "${params.output}/${name}/chromomap", mode: 'copy', pattern: "sample_overview.html"
      label 'chromomap'
      errorStrategy 'retry'
      maxRetries 3
    input:
      tuple val(name), file(chromosome), file(annotation)
    output:
      tuple val(name), file("sample_overview.html")
    script:
    if (task.attempt.toString() == '1')
      """
      #!/usr/bin/env Rscript
      library(chromoMap)
      library(ggplot2)
      library(plotly)
      p <-  chromoMap("${chromosome}","${annotation}",
            data_based_color_map = T,
            data_type = "categorical",
            segment_annotation = T,
            data_colors = list(c("lightblue", "orange", "grey")),
            legend = T, lg_y = 200, lg_x = 100,
            left_margin = 300, canvas_width = 1400, chr_length = 8, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), "sample_overview.html")
      """
    else if (task.attempt.toString() == '2')
      """
      #!/usr/bin/env Rscript
      library(chromoMap)
      library(ggplot2)
      library(plotly)
      p <-  chromoMap("${chromosome}","${annotation}",
            data_based_color_map = T,
            data_type = "categorical",
            segment_annotation = T, 
            data_colors = list(c("lightblue", "orange")),
            legend = T, lg_y = 200, lg_x = 100,
            left_margin = 300, canvas_width = 1400, chr_length = 8, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), "sample_overview.html")
      """
    else if (task.attempt.toString() == '3')
      """
      #!/usr/bin/env Rscript
      library(chromoMap)
      library(ggplot2)
      library(plotly)
      p <-  chromoMap("${chromosome}","${annotation_busco_only}",
            data_type = "categorical",
            segment_annotation = T,
            anno_col = c("lightblue"),
            left_margin = 300, canvas_width = 1400, chr_length = 8, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), "sample_overview.html")
      """
}



/*
  install.packages("chromoMap")
      library(chromoMap)
setwd ("/input")
# needs to be added to the R docker
apt-get install xdg-utils
*/