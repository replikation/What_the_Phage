process checkV_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "CheckV_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(results)
    output:
        tuple val(name), path("CheckV_results_${name}.tar.gz")
    script:
        """
        mkdir -p CheckV_results_${name}
        cp -r ${results}/* CheckV_results_${name}
        tar -czf CheckV_results_${name}.tar.gz CheckV_results_${name} ##--warning=no-file-changed
        """
    stub:
        """
        mkdir CheckV
        tar -czf CheckV_results_${name}.tar.gz CheckV --warning=no-file-changed
        """
}