process virsorter2_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "virsorter2_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(rawdir)
    output:
        tuple val(name), path("virsorter2_results_${name}.tar.gz")
    script:
        """
        mkdir virsorter2
        cp -r ${rawdir}/* virsorter2
        tar -czf virsorter2_results_${name}.tar.gz virsorter2
        """
    stub:
        """
        mkdir virsorter2
        tar -czf virsorter2_results_${name}.tar.gz virsorter2
        """
}
