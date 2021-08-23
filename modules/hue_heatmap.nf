process hue_heatmap {
    publishDir "${params.output}/${name}", mode: 'copy', pattern: "*_phage-distribution.pdf"
    label 'hue_heatmap'
    input:
        tuple val(name),val(category),  path(files)
    output:
        tuple val(name), val(category), path("*_phage-distribution.pdf") optional true

    script:
        """
        hue_heatmap_plot.py --input *.tsv --output ${name}_phage-distribution.pdf
        """
      stub:
        """
        touch ${name}_phage-distribution.pdf   
        """        
}