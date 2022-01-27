process annotation_table_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(annotation_table), path(markdown)
    output:
        tuple val(name),  path("${name}_report_annotation_table.input"), path("${name}_report_annotation_table.Rmd")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${annotation_table} ${name}_report_annotation_table.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_annotation_table.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_annotation_table.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${annotation_table} ${name}_report_annotation_table.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_annotation_table.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_annotation_table.Rmd
        """
} 
