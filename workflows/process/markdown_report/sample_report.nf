process sample_report {
    label 'ubuntu'  
    input:
        tuple val(name), path(inputs), path(rmds), path(samplemarkdown)
    output:
        tuple path(inputs), path("${name}_sample_report.Rmd")
    script:
        """
        # replace samplename
        sed -e 's/#SAMPLENAME#/${name}/g' ${samplemarkdown} > ${name}_sample_report.Rmd
        # add tool reports (separate here to control order)
        
        for FILE in ${name}_report_*.Rmd; do
            printf "\\n"  >> ${name}_sample_report.Rmd
            cat \${FILE} >> ${name}_sample_report.Rmd
            printf "\\n"  >> ${name}_sample_report.Rmd
        done
        """
    stub:
        """
        # replace samplename
        sed -e 's/#SAMPLENAME#/${name}/g' ${samplemarkdown} > ${name}_sample_report.Rmd
        # add tool reports (separate here to control order)
        for FILE in ${name}_report_*.Rmd; do
            printf "\\n"  >> ${name}_sample_report.Rmd
            cat \${FILE} >> ${name}_sample_report.Rmd
            printf "\\n"  >> ${name}_sample_report.Rmd
        done
        """
}