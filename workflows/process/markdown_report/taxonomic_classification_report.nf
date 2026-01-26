process taxonomic_classification_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(sourmash_tax), path(genomad_tax), path(markdown)
    output:
        tuple val(name),  path("${name}_report_taxonomic_classification.Rmd"), path("${name}*.inpu*")
    script:
        """
        # rename input files to avoid collisions later (needs to be ".input")
        cp ${sourmash_tax} ${name}_report_sourmash_taxonomy.input
        cp ${genomad_tax} ${name}_report_genomad_taxonomy.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#SOURMASHENV#/${name}_report_sourmash_taxonomy.input/g' ${markdown} | \
        sed -e 's/#GENOMADENV#/${name}_report_genomad_taxonomy.input/g' | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_taxonomic_classification.Rmd
        """
    stub:
        """
        # rename input files to avoid collisions later (needs to be ".input")
        cp ${sourmash_tax} ${name}_report_sourmash_taxonomy.input
        cp ${genomad_tax} ${name}_report_genomad_taxonomy.input
        # add inputfile name and sample name to markdown template
        sed -e 's/#SOURMASHENV#/${name}_report_sourmash_taxonomy.input/g' ${markdown} | \
        sed -e 's/#GENOMADENV#/${name}_report_genomad_taxonomy.input/g' | \
        sed -e 's/#NAMEENV#/${name}/g' > ${name}_report_taxonomic_classification.Rmd
        """
} 
