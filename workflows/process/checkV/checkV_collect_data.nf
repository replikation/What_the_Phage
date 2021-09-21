process checkV_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "checkV_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(results)
    output:
        tuple val(name), path("CheckV_${name}.tar.gz")
    script:
        """
        tar -czf CheckV_results_${name}.tar.gz ${results}
        """
    stub:
        """
        mkdir CheckV
        tar -czf CheckV_results_${name}.tar.gz CheckV
        """
}