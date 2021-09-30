process hue_heatmap {
    publishDir "${params.output}/${name}", mode: 'copy', pattern: "phage-distribution.pdf"
    label 'ggplot2'
    input:
        tuple val(name), path(file)
    output:
        tuple val(name), path("phage-distribution.pdf") //optional true
        tuple val(name), file("results.txt") optional true
    script:
        """
        ## hue_heatmap_plot.py --input *.tsv --output ${name}_phage-distribution.pdf ,val(category),
        linenumbers=\$(cat *.tsv | wc -l)
        if (( \${linenumbers} == 0 )) ; then
            echo "No Phages found" > results.txt
        else
            heatmap_mqt.R contig_tool_p-value_overview.tsv
        fi
        ##S
        """
      stub:
        """
        touch phage-distribution.pdf   
        """        
}