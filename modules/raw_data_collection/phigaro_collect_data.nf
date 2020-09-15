process phigaro_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "phigaro_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(rawdir)
    output:
        tuple val(name), path("phigaro_results_${name}.tar.gz")
    script:
        """
        mkdir phigaro
        cp -r ${rawdir}/* phigaro
        tar -czf phigaro_results_${name}.tar.gz phigaro
        """
}
