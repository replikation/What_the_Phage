process virfinder_collect_data {
    label 'ubuntu'
    input:
        tuple val(name), file(output_lists)
    output:
        tuple val(name), file("virfinder_results_${name}.tar.gz")
    script:
        """
        mkdir -p virfinder
        cp ${output_lists} virfinder
        tar -czf virfinder_results_${name}.tar.gz virfinder
        """
    stub:
        """
        mkdir virfinder
        tar -czf virfinder_results_${name}.tar.gz virfinder
        """
}
