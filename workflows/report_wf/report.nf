process report {
    publishDir "${params.output}/report", mode: 'copy'
    label 'python'

    input:
        path(json_files)
        path(template)
        
    output:
        path("report.html")
    script:
        
        """
        inject_json.py ${template} ${json_files} report.html
        """ 

    stub:
        """
        touch report.html
        """
}
   