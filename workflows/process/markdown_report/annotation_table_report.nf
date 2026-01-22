process annotation_table_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(annotation_table), path(annotation_waffle), path(markdown)
    output:
        tuple val(name), path("${name}_report_annotation_table.Rmd"), path("${name}_report_annotation_*.inpu*")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${annotation_table} ${name}_report_annotation_table.input
        cp ${annotation_waffle} ${name}_report_annotation_waffle.input.svg
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_annotation_table.input/g' ${markdown} | \
        sed -e 's/#WAFFLEENV#/${name}_report_annotation_waffle.input.svg/g' | \
        sed -e "s|#RESULTSDIR#|${params.output}/${name}/annotation_results/summary/|g" | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_annotation_table.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${annotation_table} ${name}_report_annotation_table.input
        cp ${annotation_waffle} ${name}_report_annotation_waffle.input.svg
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_annotation_table.input/g' ${markdown} | \
        sed -e 's/#WAFFLEENV#/${name}_report_annotation_waffle.input.svg/g' | \
        sed -e "s|#RESULTSDIR#|${params.output}/${name}/annotation_results/summary/|g" | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_annotation_table.Rmd
        """
} 
