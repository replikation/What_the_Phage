process upsetr_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(markdown), path(upsetR_file)
    output:
        tuple val(name), path("${name}_report_upsetR_file.input"), path("${name}_report_UpsetR.Rmd")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${upsetR_file} ${name}_report_upsetR_file.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_upsetR_file.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_UpsetR.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${upsetR_file} ${name}_report_upsetR_file.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_upsetR_file.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_UpsetR.Rmd
        """
}