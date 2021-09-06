process hue_heatmap {
    publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
    label 'ggplot2'
    input:
        tuple val(name), path(files)
    output:
        tuple val(name), path("phage-distribution.pdf") //optional true

    script:
        """
        ## hue_heatmap_plot.py --input *.tsv --output ${name}_phage-distribution.pdf ,val(category),

        R heatmap_mqt.R 
        ##S
        """
      stub:
        """
        touch phage-distribution.pdf   
        """        
}