process hue_heatmap {
    publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
    label 'ubuntu'
    input:
        tuple val(name), path(files)
    output:
        tuple val(name), path("") //optional true

    script:
        """
        
        """
      stub:
        """
        touch phage-distribution.pdf   
        """        
}