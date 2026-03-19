process results_to_json {
    publishDir "${params.output}/report", mode: 'copy'
    label 'python'

    input:
        tuple val(name), path(all_files)

    output:
        tuple val(name), path("${name}_results.json")
    script:
        // takes only csv and tsv files
        """
        results_to_json.py --name "${name}" --output "${name}_results.json" ${all_files}
        """ 

    stub:
    """
    touch ${name}_results.json
    """
}
   