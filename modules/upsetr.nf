process upsetr_plot {
      publishDir "${params.output}/${name}", mode: 'copy', pattern: "upsetr.svg"
      label 'upsetr'
      errorStrategy{task.exitStatus=1 ?'ignore':'terminate'}
    input:
      tuple val(name), file(files)
    output:
      tuple val(name), file("upsetr.svg")
    script:
      """
      #!/usr/bin/env Rscript

      library(UpSetR)

      sets <- list(
      virsorter = sort(as.character(read.csv("virsorter.txt", header = F, sep = "=", stringsAsFactors = F)\$V1)),
      virfinder = sort(as.character(read.csv("virfinder.txt", header = F, sep = "=", stringsAsFactors = F)\$V1)),
      marvel = sort(as.character(read.csv("marvel.txt", header = F, sep = "=", stringsAsFactors = F)\$V1)),
      metaphinder = sort(as.character(read.csv("metaphinder.txt", header = F, sep = "=", stringsAsFactors = F)\$V1)),
      deepvirfinder = sort(as.character(read.csv("deepvirfinder.txt", header = F, sep = "=", stringsAsFactors = F)\$V1)),
      pprmeta = sort(as.character(read.csv("PPRmeta.txt", header = F, sep = "=", stringsAsFactors = F)\$V1)))

      svg(filename="upsetr.svg", 
          width=10, 
          height=8, 
          pointsize=12)

      upset(fromList(sets), sets = c("pprmeta","deepvirfinder","metaphinder","marvel","virfinder","virsorter"), 
          mainbar.y.label = "No. of common viral contigs", sets.x.label = "No. of identified \\nviral contigs", 
          order.by = "freq", sets.bar.color = "#56B4E9", keep.order = T, 
          text.scale = 1.4, point.size = 2.6, line.size = 0.8,
          set_size.show = TRUE, empty.intersections = "off")

      dev.off()
      """
}