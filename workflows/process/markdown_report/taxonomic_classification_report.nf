process taxonomic_classification_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(taxonomic_classification), path(markdown)
    output:
        tuple val(name),  path("${name}_report_taxonomic_classification.input"), path("${name}_report_taxonomic_classification.Rmd")
    script:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${taxonomic_classification} ${name}_report_taxonomic_classification.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_taxonomic_classification.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_taxonomic_classification.Rmd
        """
    stub:
        """
        # rename input file to avoid collisions later (needs to be ".input")
        cp ${taxonomic_classification} ${name}_report_taxonomic_classification.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#RESULTSENV#/${name}_report_taxonomic_classification.input/g' ${markdown} | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_taxonomic_classification.Rmd
        """
} 
