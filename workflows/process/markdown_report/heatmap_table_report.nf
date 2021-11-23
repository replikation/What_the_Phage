process heatmap_table_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(heatmap_overview_file), path(markdown)
    output:
        tuple val(name), path("${name}_report_heatmap_table.input"), path("${name}_report_heatmap_table.Rmd")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${heatmap_overview_file} ${name}_report_heatmap_table.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_heatmap_table.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_heatmap_table.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${heatmap_overview_file} ${name}_report_heatmap_table.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_heatmap_table.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_heatmap_table.Rmd
        """
} 
