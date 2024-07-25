      #!/usr/bin/env Rscript
      library(chromoMap)
      library(ggplot2)
      library(plotly)
      input <- read.delim("${chromosome}", sep = '\t', header = FALSE)
      sizeh <- ( nrow(input) * 80 )
      p <-  chromoMap("${chromosome}","${annotation}",
            data_based_color_map = T,
            data_type = "categorical",
            segment_annotation = T,
            data_colors = list(c("red", "lightblue", "orange", "green")),
            labels=F,
            legend=T, lg_x = 300,
            left_margin = 340, canvas_width = 1500, canvas_height = sizeh, chr_length = 12, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), "sample_overview_${type}.html")