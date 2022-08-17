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

      files_for_upset <- list.files(path="./", full.names=T, pattern=".txt")

      sets <- lapply(files_for_upset, readLines)

      sets_names <- sapply(files_for_upset, function(x){
        splits <- strsplit(strsplit(x,"//")[[1]][2],".txt")[[1]]
        return(splits)
      })

      names(sets) <- sets_names

      sets <- sets[order(sapply(sets,length),decreasing=T)]

      svg(filename="upsetr.svg", 
          width=10, 
          height=8, 
          pointsize=12)

      #nsets = 20, nintersects = 40
      upset(fromList(sets), sets = names(sets),
          mainbar.y.label = "No. of shared phage contigs", sets.x.label = "Number of phage \\ncontigs per tool ", 
          order.by = "freq", sets.bar.color = "#56B4E9", keep.order = F, 
          text.scale = 1.4, point.size = 2.6, line.size = 0.8, set_size.show = FALSE)

      dev.off()
      """
    stub:
        """
        touch upsetr.svg
        """
}