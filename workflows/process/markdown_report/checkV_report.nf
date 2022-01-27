process checkV_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(checkV_file), path(markdown)
    output:
        tuple val(name),  path("${name}_report_checkV_file.input"), path("${name}_report_checkV_file.Rmd")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${checkV_file} ${name}_report_checkV_file.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_checkV_file.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_checkV_file.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${checkV_file} ${name}_report_checkV_file.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_checkV_file.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_checkV_file.Rmd
        """
} 
