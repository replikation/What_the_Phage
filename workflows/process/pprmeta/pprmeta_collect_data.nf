process pprmeta_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "pprmeta_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(output_lists)
    output:
        tuple val(name), path("pprmeta_results_${name}.tar.gz")
    script:
        """
        cat ${output_lists} | head -1 > ${name}_overview.txt
        tail -q -n+2 ${output_lists} >> ${name}_overview.txt
        tar -czf pprmeta_results_${name}.tar.gz ${name}_overview.txt
        """
}
